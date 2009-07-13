#!/usr/local/bin/python

"""Returns the age in hours of the oldest file in a directory hierachy.

This should work with munin-node (Unix) and munin-node32 (MS Windows)

Created 2008-11-12 by Maximillian Dornseif
"""

import sys
import os
import os.path
import time

def ltrim(text, length=29, replacement='...'):
    """Trim a strin att the beginning to be not longern than length characters."""

    if len(text) > length:
        return '%s%s' % (replacement, text[-length:])
    return text


def main():
    """Contains all usefull work."""

    # keep windows from messing with line endings
    if sys.platform.startswith("win") and hasattr(sys.stdout, 'fileno'):
        import msvcrt
        msvcrt.setmode(sys.stdout.fileno(), os.O_BINARY)

    if 'dirnames' in os.environ:
        dirnames = os.environ['dirnames']
    else:
        # default value
        dirnames = r'C:\Inhouse\workdir\INVOIC C:\Inhouse\ORDERS C:\Inhouse\workdir\tmp'
    
    if sys.argv[-1] == "name" and sys.platform.startswith('win'):
        sys.stdout.write('oldestfile')
    elif sys.argv[-1] == "config":
        out = []
        out.append('graph_title oldest file')
        out.append('graph_vlabel hours')
        out.append('graph_args --lower-limit 0')
        out.append('graph_category other')
        for i, dirname in enumerate(dirnames.strip().split()):
            out.append('p%d_age.label oldest file @%s' % (i, ltrim(dirname.replace('\\', '/'))))
            out.append('p%d_age.type GAUGE' % (i, ))
            out.append('p%d_age.warning %d' % (i, (24)+1))
            out.append('p%d_age.critical %d' % (i, (3*24)+1))
            out.append('p%d_count.label no of files @%s' % (i, ltrim(dirname.replace('\\', '/'))))
            out.append('p%d_count.type GAUGE' % (i, ))

        if sys.platform.startswith('win'):
            sys.stdout.write('\n'.join(out))
            sys.stdout.write('\n.\n')
        else:
            print '\n'.join(out)
    
    else:
        out = []
        for i, dirname in enumerate(dirnames.split()):
            oldest = time.time()
            count = 0
            for root, dirs, files in os.walk(dirname):
                for subdirname in dirs:
                    if subdirname.startswith('.'):
                        dirs.remove(subdirname)  # don't visit .foo directories
                for name in files:
                    try:
                        age = os.path.getctime(os.path.join(root, name)) 
                        oldest = min([age, oldest])
                        count += 1
                    except OSError:
                        pass
             
            delta = time.time() - oldest
            out.append("p%d_age.value %d" % (i, delta/60/60))
            out.append("p%d_count.value %d" % (i, count))

        if sys.platform.startswith('win'):
            sys.stdout.write('\n'.join(out))
            sys.stdout.write('\n.\n')
        else:
            print '\n'.join(out)

main()
