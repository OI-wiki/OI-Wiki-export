# -*- coding: utf-8 -*-

from __future__ import (unicode_literals, division, absolute_import,
                        print_function)
import six

__license__   = 'GPL v3'
__copyright__ = '2020, Jim Miller, 2011, Grant Drake <grant.drake@gmail.com>'
__docformat__ = 'restructuredtext en'

import logging
logger = logging.getLogger(__name__)

import traceback
import time
from io import StringIO
from collections import defaultdict

from calibre.ptempfile import PersistentTemporaryFile
from calibre.ebooks.oeb.polish.container import get_container
from calibre.ebooks.conversion.cli import main as ebook_convert_cli_main

from calibre_plugins.epubmerge.epubmerge import doMerge, doUnMerge

# pulls in translation files for _() strings
try:
    load_translations()
except NameError:
    pass # load_translations() added in calibre 1.9

# ------------------------------------------------------------------------------
#
#              Functions to perform downloads using worker jobs
#
# ------------------------------------------------------------------------------

def do_merge_bg(args,
                cpus,
                notification=lambda x,y:x):
    # logger.debug("do_merge_bg(%s,%s)"%(args,cpus))

    # This server is an arbitrary_n job, so there is a notifier available.
    ## for purposes of %done, autoconvert, merging output are each
    ## considered 1/2 of total.
    def notify_progress(percent):
        notification(max(percent/2,0.01), _('Autoconverting...'))

    # Set the % complete to a small number to avoid the 'unavailable' indicator
    notify_progress(0.01)

    for j in range(0,len(args['inputepubfns'])):
        fn = args['inputepubfns'][j]
        title = args['epubtitles'][fn]
        try:
            container = get_container(fn)
            if container.opf_version_parsed.major >= 3:
                print("=" * 50)
                print("Found EPUB3 for %s, automatically creating a temporary EPUB2 for merging...\n"%title)
                # this temp file is deleted when the BG process quits,
                # so don't expect it to still be there.
                epub2 = PersistentTemporaryFile(prefix="epub2_",
                                                suffix=".epub",
                                                dir=args['tdir'])
                fn2 = epub2.name
                # ebook-convert epub3.epub epub2.epub --epub-version=2
                ebook_convert_cli_main(['epubmerge calling convert',fn,fn2,'--epub-version=2','--no-default-epub-cover'])
                args['inputepubfns'][j] = fn2
                print("Converted to temporary EPUB2: %s"%fn2)
            notify_progress(float(j)/len(args['inputepubfns']))
        except:
            print("=" * 20)
            print("Exception auto converting %s to EPUB2 from EPUB3"%title)
            print("Quiting...")
            print("=" * 50)
            raise

    def notify_progress(percent):
        notification(percent/2 + 0.5, _('Merging...'))

    print("=" * 50)
    print("\nBeginning Merge...\n")
    print("=" * 50)

    doMerge(args['outputepubfn'],
            args['inputepubfns'],
            args['authoropts'],
            args['titleopt'],
            args['descopt'],
            args['tags'],
            args['languages'],
            args['titlenavpoints'],
            args['originalnavpoints'],
            args['flattentoc'],
            args['printtimes'],
            args['coverjpgpath'],
            args['keepmetadatafiles'],
            notify_progress=notify_progress)
    print("=" * 50)
    print("\nFinished Merge...\n")
    print("=" * 50)
