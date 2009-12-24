<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.hadoop.conf.*" %>
<%@ page import="org.apache.hadoop.fs.*" %>
<%@ page import="org.apache.hadoop.fs.FileSystem" %>
<%@ page import="org.apache.hadoop.io.*" %>
<%@ page import="org.apache.hadoop.mapred.*" %>
<%@ page import="org.apache.lucene.index.*" %>
<%@ page import="org.apache.lucene.store.*" %>
<%@ page import="org.apache.nutch.indexer.*" %>
<%@ page import="org.apache.nutch.util.*" %>
<%@ page import="org.apache.nutch.crawl.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!-- Display Statistics about a Nutch Index. Developed 2009 for Hudora. -->

<%!
    private Path dir;
    private FileSystem fs;
    private Configuration conf;

    private Directory getDirectory(Path file) throws IOException {
        if ("file".equals(this.fs.getUri().getScheme())) {
            Path qualified = file.makeQualified(FileSystem.getLocal(conf));
            File fsLocal = new File(qualified.toUri());
            return FSDirectory.getDirectory(fsLocal.getAbsolutePath());
        } else {
            return new FsDirectory(this.fs, file, false, this.conf);
        }
    }

    public void jspInit() {
        try {
            conf = NutchConfiguration.get(getServletConfig().getServletContext());
            dir = new Path(conf.get("searcher.dir", "crawl"));
            fs = FileSystem.get(conf);
        } catch (IOException ex) {
            ex.printStackTrace();
            throw new RuntimeException(ex);
        }
    }

    private IndexReader openReader() {
        final Path indexDir = new Path(dir, "index");
        final Path indexesDir = new Path(dir, "indexes");

        try {
            // initialize index reader
            if (fs.exists(indexDir)) {
                return IndexReader.open(getDirectory(indexDir));
            } else {
                final List<Path> vDirs = new ArrayList<Path>();
                final FileStatus [] fstats = fs.listStatus(indexesDir, HadoopFSUtil.getPassDirectoriesFilter(fs));
                Path [] directories = HadoopFSUtil.getPaths(fstats);
                for (final Path directory : directories) {
                    if (fs.isFile(new Path(directory, Indexer.DONE_NAME))) vDirs.add(directory);
                }

                directories = new Path[vDirs.size()];
                for(int i = 0; vDirs.size()>0; i++) directories[i] = vDirs.remove(0);
                final IndexReader [] readers = new IndexReader[directories.length];
                for (int i = 0; i < directories.length; i++) readers[i] = IndexReader.open(getDirectory(directories[i]));
                return new MultiReader(readers);
            }
        } catch (IOException ex) {
            ex.printStackTrace();
            throw new RuntimeException(ex);
        }
    }

    private long numTerms(final IndexReader indexReader) throws IOException {
        long numTerms = 0;
        final TermEnum te = indexReader.terms();
        try {
            while (te.next()) numTerms++;
            return numTerms;
        } finally {
            te.close();
        }
    }

    private String lastModified(final IndexReader indexReader) throws IOException {
        return new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ").format(
               new Date(IndexReader.lastModified(indexReader.directory())));
    }

    private String crawlDbStat() throws IOException {
        final StringWriter output = new StringWriter();
        final PrintWriter writer  = new PrintWriter(output);

        final CrawlDbReader dbr = new CrawlDbReader() {
            @Override public void processStatJob(final String crawlDb, final Configuration config, final boolean sort) throws IOException {
                if (LOG.isInfoEnabled()) LOG.info("CrawlDb statistics start: " + crawlDb);
                final Path tmpFolder = new Path(crawlDb, "stat_tmp" + System.currentTimeMillis());
                final JobConf job = new NutchJob(config);
                job.setJobName("stats " + crawlDb);
                job.setBoolean("db.reader.stats.sort", sort);

                FileInputFormat.addInputPath(job, new Path(crawlDb, CrawlDb.CURRENT_NAME));
                job.setInputFormat(SequenceFileInputFormat.class);
                job.setMapperClass(CrawlDbStatMapper.class);
                job.setCombinerClass(CrawlDbStatCombiner.class);
                job.setReducerClass(CrawlDbStatReducer.class);

                FileOutputFormat.setOutputPath(job, tmpFolder);
                job.setOutputFormat(SequenceFileOutputFormat.class);
                job.setOutputKeyClass(Text.class);
                job.setOutputValueClass(LongWritable.class);

                try {
                    JobClient.runJob(job);
                } catch (IOException ex) {
                    if (LOG.isErrorEnabled()) LOG.error("job failed", ex);
                }

                // reading the result
                final FileSystem fileSystem = FileSystem.get(config);
                final SequenceFile.Reader [] readers = SequenceFileOutputFormat.getReaders(config, tmpFolder);

                final Text key = new Text();
                final LongWritable value = new LongWritable();

                final TreeMap<String, LongWritable> stats = new TreeMap<String, LongWritable>();
                for (final SequenceFile.Reader reader : readers) {
                    while (reader.next(key, value)) {
                        final String k = key.toString();
                        LongWritable val = stats.get(k);
                        if (val == null) {
                            val = new LongWritable();
                            if (k.equals("scx")) val.set(Long.MIN_VALUE);
                            if (k.equals("scn")) val.set(Long.MAX_VALUE);
                            stats.put(k, val);
                        }
                        if (k.equals("scx")) {
                            if (val.get() < value.get()) val.set(value.get());
                        } else if (k.equals("scn")) {
                            if (val.get() > value.get()) val.set(value.get());
                        } else {
                            val.set(val.get() + value.get());
                        }
                    }
                    reader.close();
                }

                final LongWritable totalCnt = stats.get("T");
                stats.remove("T");
                writer.println("TOTAL urls:\t" + totalCnt.get());
                for (final Map.Entry<String, LongWritable> entry : stats.entrySet()) {
                    final String k = entry.getKey();
                    final LongWritable val = entry.getValue();
                    if (k.equals("scn"))      writer.println("min score:\t" + val.get() / 1000.0f);
                    else if (k.equals("scx")) writer.println("max score:\t" + val.get() / 1000.0f);
                    else if (k.equals("sct")) writer.println("avg score:\t" + (float) ((((double)val.get()) / totalCnt.get()) / 1000.0));
                    else if (k.startsWith("status")) {
                        String[] st = k.split(" ");
                        int code = Integer.parseInt(st[1]);
                        if (st.length > 2) writer.println("   " + st[2] +" :\t" + val);
                        else writer.println(st[0] + " " + code + " (" + CrawlDatum.getStatusName((byte)code) + "):\t" + val);
                    } else writer.println(k + ":\t" + val);
                }
                // removing the tmp folder
                fileSystem.delete(tmpFolder, true);
                if (LOG.isInfoEnabled()) { LOG.info("CrawlDb statistics: done"); }
            }
        };
        dbr.processStatJob(new Path(dir, "crawldb").toString(), conf, true);
        return output.toString();
    }
%>
<html>
<head><title>index statistics</title></head>
<body>
<div>
    <% final IndexReader indexReader = openReader(); try { %>
    index:
    <ul>
    <li>numDocs: <strong><%= indexReader.numDocs() %></strong></li>
    <li>numTerms: <strong><%= numTerms(indexReader) %></strong></li>
    <li>lastModified: <strong><%= lastModified(indexReader) %></strong></li>
    </ul>
    <% } finally { indexReader.close(); } %>
</div>
<div>
    crawldb raw:
    <pre><%= crawlDbStat() %></pre>
</div>
</body>
</html>