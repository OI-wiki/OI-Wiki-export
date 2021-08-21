#!/usr/bin/python
# -*- coding: utf-8 -*-

__license__   = 'GPL v3'
__copyright__ = '2020, Jim Miller'
__docformat__ = 'restructuredtext en'

import sys, os
import logging
logger = logging.getLogger(__name__)

version="2.11.0"

# py2 vs py3 transition
from six import text_type as unicode
from six.moves.urllib.parse import unquote
from io import BytesIO

import re
from posixpath import normpath
from optparse import OptionParser
from functools import partial

from zipfile import ZipFile, ZIP_STORED, ZIP_DEFLATED
from time import time, sleep

from xml.dom.minidom import parse, parseString, getDOMImplementation, Element

try:
    from six import ensure_binary
except:
    ## Calibre 3's version of six doesn't include ensure_binary.  Copy
    ## rather than include own six.py.

#For this function:
# Copyright (c) 2010-2018 Benjamin Peterson
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

    from six import text_type, binary_type
    def ensure_binary(s, encoding='utf-8', errors='strict'):
        """Coerce **s** to six.binary_type.

        For Python 2:
          - `unicode` -> encoded to `str`
          - `str` -> `str`

        For Python 3:
          - `str` -> encoded to `bytes`
          - `bytes` -> `bytes`
        """
        if isinstance(s, text_type):
            return s.encode(encoding, errors)
        elif isinstance(s, binary_type):
            return s
        else:
            raise TypeError("not expecting type '%s'" % type(s))


def main(argv,usage=None):
    loghandler=logging.StreamHandler()
    loghandler.setFormatter(logging.Formatter("%(filename)s(%(lineno)d): %(message)s"))
    logger.addHandler(loghandler)
    loghandler.setLevel(logging.DEBUG)
    logger.setLevel(logging.DEBUG)

    if not usage:
    # read in args, anything starting with -- will be treated as --<varible>=<value>
        usage = "usage: python %prog"
    optparser = OptionParser(usage+''' [options] <input epub> [<input epub>...]

Given list of epubs will be merged together into one new epub.
''')

    optparser.add_option("-o", "--output", dest="outputopt", default="merge.epub",
                      help="Set OUTPUT file, Default: merge.epub", metavar="OUTPUT")
    optparser.add_option("-t", "--title", dest="titleopt", default=None,
                      help="Use TITLE as the metadata title.  Default: '<first epub title> Anthology'", metavar="TITLE")
    optparser.add_option("-d", "--description", dest="descopt", default=None,
                      help="Use DESC as the metadata description.  Default: '<epub title> by <author>' for each epub.", metavar="DESC")
    optparser.add_option('--debug',
                      action='store_true', dest='debug',
                      help='Show debug and notice output.', )
    optparser.add_option("-a", "--author",
                      action="append", dest="authoropts", default=[],
                      help="Use AUTHOR as a metadata author, multiple authors may be given, Default: <All authors from epubs>", metavar="AUTHOR")
    optparser.add_option("-g", "--tag",
                      action="append", dest="tagopts", default=[],
                      help="Include TAG as dc:subject tag, multiple tags may be given, Default: None", metavar="TAG")
    optparser.add_option("-l", "--language",
                      action="append", dest="languageopts", default=[],
                      help="Include LANG as dc:language tag, multiple languages may be given, Default: en", metavar="LANG")
    optparser.add_option("-n", "--no-titles-in-toc",
                      action="store_false", dest="titlenavpoints", default=True,
                      help="Default is to put an entry in the TOC for each epub, nesting each epub's chapters under it.",)
    optparser.add_option("-N", "--no-original-toc",
                      action="store_false", dest="originalnavpoints", default=True,
                      help="Default is to include the TOC from each original epub.",)
    optparser.add_option("-f", "--flatten-toc",
                      action="store_true", dest="flattentoc",
                      help="Flatten TOC down to one level only.",)
    optparser.add_option("-c", "--cover", dest="coveropt", default=None,
                      help="Path to a jpg to use as cover image.", metavar="COVER")
    optparser.add_option("-k", "--keep-meta",
                      action="store_true", dest="keepmeta",
                      help="Keep original metadata files in merged epub.  Use for UnMerging.",)
    optparser.add_option("-s", "--source", dest="sourceopt", default=None,
                      help="Include URL as dc:source and dc:identifier(opf:scheme=URL).", metavar="URL")

    optparser.add_option("-u", "--unmerge",
                      action="store_true", dest="unmerge",
                      help="UnMerge an existing epub that was created by merging with --keep-meta.",)
    optparser.add_option("-D", "--outputdir", dest="outputdir", default=".",
                      help="Set output directory for unmerge, Default: (current dir)", metavar="OUTPUTDIR")

    (options, args) = optparser.parse_args(argv)

    if not options.debug:
        logger.setLevel(logging.WARNING)
    else:
        import platform
        logger.debug("    OS Version:%s"%platform.platform())
        logger.debug("Python Version:%s"%sys.version)
        logger.debug("EpubMerge Vers:%s"%version)

    ## Add .epub if not already there.
    if not options.outputopt.lower().endswith(".epub"):
        options.outputopt=options.outputopt+".epub"

    logger.debug("output file: "+options.outputopt)

    if not args:
        optparser.print_help()
        return

    if options.unmerge:
        doUnMerge(args[0],options.outputdir)
    else:
        doMerge(options.outputopt,
                args,
                options.authoropts,
                options.titleopt,
                options.descopt,
                options.tagopts,
                options.languageopts,
                options.titlenavpoints,
                options.originalnavpoints,
                options.flattentoc,
                coverjpgpath=options.coveropt,
                keepmetadatafiles=options.keepmeta,
                source=options.sourceopt
                )

def cond_print(flag,arg):
    if flag:
        logger.debug(arg)

imagetypes = {
    'jpg':'image/jpeg',
    'jpeg':'image/jpeg',
    'png':'image/png',
    'gif':'image/gif',
    'svg':'image/svg+xml',
    }

def doMerge(outputio,
            files,
            authoropts=[],
            titleopt=None,
            descopt=None,
            tags=[],
            languages=['en'],
            titlenavpoints=True,
            originalnavpoints=True,
            flattentoc=False,
            printtimes=False,
            coverjpgpath=None,
            keepmetadatafiles=False,
            source=None,
            notify_progress=lambda x:x):
    '''
    outputio = output file name or BytesIO.
    files = list of input file names or BytesIOs.
    authoropts = list of authors to use, otherwise add from all input
    titleopt = title, otherwise '<first title> Anthology'
    descopt = description, otherwise '<title> by <author>' list for all input
    tags = dc:subject tags to include, otherwise none.
    languages = dc:language tags to include
    titlenavpoints if true, put in a new TOC entry for each epub, nesting each epub's chapters under it
    originalnavpoints if true, include the original TOCs from each epub
    flattentoc if true, flatten TOC down to one level only.
    coverjpgpath, Path to a jpg to use as cover image.
    '''

    notify_progress(0.0) # sets overall progress to 50%
    printt = partial(cond_print,printtimes)

    ## Python 2.5 ZipFile is rather more primative than later
    ## versions.  It can operate on a file, or on a BytesIO, but
    ## not on an open stream.  OTOH, I suspect we would have had
    ## problems with closing and opening again to change the
    ## compression type anyway.

    filecount=0
    t = time()

    ## Write mimetype file, must be first and uncompressed.
    ## Older versions of python(2.4/5) don't allow you to specify
    ## compression by individual file.
    ## Overwrite if existing output file.
    outputepub = ZipFile(outputio, "w", compression=ZIP_STORED, allowZip64=True)
    outputepub.debug = 3
    outputepub.writestr("mimetype", "application/epub+zip")
    outputepub.close()

    ## Re-open file for content.
    outputepub = ZipFile(outputio, "a", compression=ZIP_DEFLATED, allowZip64=True)
    outputepub.debug = 3

    ## Create META-INF/container.xml file.  The only thing it does is
    ## point to content.opf
    containerdom = getDOMImplementation().createDocument(None, "container", None)
    containertop = containerdom.documentElement
    containertop.setAttribute("version","1.0")
    containertop.setAttribute("xmlns","urn:oasis:names:tc:opendocument:xmlns:container")
    rootfiles = containerdom.createElement("rootfiles")
    containertop.appendChild(rootfiles)
    rootfiles.appendChild(newTag(containerdom,"rootfile",{"full-path":"content.opf",
                                                          "media-type":"application/oebps-package+xml"}))
    outputepub.writestr("META-INF/container.xml",containerdom.toprettyxml(indent='   ',encoding='utf-8'))

    ## Process input epubs.

    items = [] # list of (id, href, type) tuples(all strings) -- From .opfs' manifests
    items.append(("ncx","toc.ncx","application/x-dtbncx+xml")) ## we'll generate the toc.ncx file,
                                                               ## but it needs to be in the items manifest.
    itemrefs = [] # list of strings -- idrefs from .opfs' spines
    navmaps = [] # list of navMap DOM elements -- TOC data for each from toc.ncx files
    is_ffdl_epub = [] # list of t/f

    itemhrefs = {} # hash of item[id]s to itemref[href]s -- to find true start of book(s).
    firstitemhrefs = []

    booktitles = [] # list of strings -- Each book's title
    allauthors = [] # list of lists of strings -- Each book's list of authors.

    filelist = []

    printt("prep output:%s"%(time()-t))
    t = time()

    booknum=1
    firstmetadom = None
    for file in files:
        if file == None : continue

        book = "%d" % booknum
        bookdir = "%d/" % booknum
        bookid = "a%d" % booknum

        epub = ZipFile(file, 'r')

        ## Find the .opf file.
        container = epub.read("META-INF/container.xml")
        containerdom = parseString(container)
        rootfilenodelist = containerdom.getElementsByTagNameNS("*","rootfile")
        rootfilename = rootfilenodelist[0].getAttribute("full-path")

        ## Save the path to the .opf file--hrefs inside it are relative to it.
        relpath = get_path_part(rootfilename)

        metadom = parseString(epub.read(rootfilename))
        # logger.debug("metadom:%s"%epub.read(rootfilename))
        if booknum==1 and not source:
            try:
                firstmetadom = metadom.getElementsByTagNameNS("*","metadata")[0]
                source=unicode(firstmetadom.getElementsByTagName("dc:source")[0].firstChild.data)
            except:
                source=""

        is_ffdl_epub.append(False)
        ## looking for any of:
        ##   <dc:contributor id="id-2">FanFicFare [https://github.com/JimmXinu/FanFicFare]</dc:contributor>
        ##   <dc:identifier opf:scheme="FANFICFARE-UID">test1.com-u98765-s68</dc:identifier>
        ##   <dc:identifier id="fanficfare-uid">fanficfare-uid:test1.com-u98765-s68</dc:identifier>
        ## FFF writes dc:contributor and dc:identifier
        ## Sigil changes the unique-identifier, but leaves dc:contributor
        ## Calibre epub3->epub2 convert changes dc:contributor and modifies dc:identifier
        for c in metadom.getElementsByTagName("dc:contributor") + metadom.getElementsByTagName("dc:identifier"):
            # logger.debug("dc:contributor/identifier:%s"%getText(c.childNodes))
            # logger.debug("dc:contributor/identifier:%s / %s"%(c.getAttribute('opf:scheme'),c.getAttribute('id')))
            if ( getText(c.childNodes) in ["fanficdownloader [http://fanficdownloader.googlecode.com]",
                                           "FanFicFare [https://github.com/JimmXinu/FanFicFare]"]
                 or 'fanficfare-uid' in c.getAttribute('opf:scheme').lower()
                 or 'fanficfare-uid' in c.getAttribute('id').lower() ):
                # logger.debug("------------> is_ffdl_epub <-----------------")
                is_ffdl_epub[-1] = True # set last.
                break;

        ## Save indiv book title
        try:
            booktitles.append(metadom.getElementsByTagName("dc:title")[0].firstChild.data)
        except:
            booktitles.append("(Title Missing)")

        ## Save authors.
        authors=[]
        for creator in metadom.getElementsByTagName("dc:creator"):
            try:
                if( creator.getAttribute("opf:role") == "aut" or not creator.hasAttribute("opf:role") and creator.firstChild != None):
                    authors.append(creator.firstChild.data)
            except:
                pass
        if len(authors) == 0:
            authors.append("(Author Missing)")
        allauthors.append(authors)

        if keepmetadatafiles:
            itemid=bookid+"rootfile"
            itemhref = rootfilename
            href=bookdir+itemhref
            logger.debug("write rootfile %s to %s"%(itemhref,href))
            outputepub.writestr(href,
                                epub.read(itemhref))
            items.append((itemid,href,"origrootfile/xml"))

        # spin through the manifest--only place there are item tags.
        # Correction--only place there *should* be item tags.  But
        # somebody found one that did.
        manifesttag=metadom.getElementsByTagNameNS("*","manifest")[0]
        for item in manifesttag.getElementsByTagNameNS("*","item"):
            itemid=bookid+item.getAttribute("id")
            itemhref = normpath(unquote(item.getAttribute("href"))) # remove %20, etc.
            href=bookdir+relpath+itemhref
            # if item.getAttribute("properties") == "nav":
            #     # epub3 TOC file is only one with this type--as far as I know.
            #     # grab the whole navmap, deal with it later.
            # el
            if item.getAttribute("media-type") == "application/x-dtbncx+xml":
                # epub2 TOC file is only one with this type--as far as I know.
                # grab the whole navmap, deal with it later.
                tocdom = parseString(epub.read(normpath(relpath+item.getAttribute("href"))))

                # update all navpoint ids with bookid for uniqueness.
                for navpoint in tocdom.getElementsByTagNameNS("*","navPoint"):
                    navpoint.setAttribute("id",bookid+navpoint.getAttribute("id"))

                # update all content paths with bookdir for uniqueness.
                for content in tocdom.getElementsByTagNameNS("*","content"):
                    content.setAttribute("src",normpath(bookdir+relpath+content.getAttribute("src")))

                navmaps.append(tocdom.getElementsByTagNameNS("*","navMap")[0])

                if keepmetadatafiles:
                    logger.debug("write toc.ncx %s to %s"%(relpath+itemhref,href))
                    outputepub.writestr(href,
                                        epub.read(normpath(relpath+itemhref)))
                    items.append((itemid,href,"origtocncx/xml"))
            else:
                #href=href.encode('utf8')
                # logger.debug("item id: %s -> %s:"%(itemid,href))
                itemhrefs[itemid] = href
                if href not in filelist:
                    try:
                        outputepub.writestr(href,
                                            epub.read(normpath(relpath+itemhref)))
                        if re.match(r'.*/(file|chapter)\d+\.x?html',href):
                            filecount+=1
                        items.append((itemid,href,item.getAttribute("media-type")))
                        filelist.append(href)
                    except KeyError as ke: # Skip missing files.
                        logger.info("Skipping missing file %s (%s)"%(href,relpath+itemhref))
                        del itemhrefs[itemid]

        itemreflist = metadom.getElementsByTagNameNS("*","itemref")
        # logger.debug("itemhrefs:%s"%itemhrefs)
        logger.debug("bookid:%s"%bookid)
        logger.debug("itemreflist[0].getAttribute(idref):%s"%itemreflist[0].getAttribute("idref"))

        # Looking for the first item in itemreflist that wasn't
        # discarded due to missing files.
        for itemref in itemreflist:
            idref = bookid+itemref.getAttribute("idref")
            if idref in itemhrefs:
                firstitemhrefs.append(itemhrefs[idref])
                break

        for itemref in itemreflist:
            itemrefs.append(bookid+itemref.getAttribute("idref"))
            # logger.debug("adding to itemrefs:%s"%itemref.toprettyxml())

        notify_progress(float(booknum-1)/len(files))
        booknum=booknum+1;

    printt("after file loop:%s"%(time()-t))
    t = time()

    ## create content.opf file.
    uniqueid="epubmerge-uid-%d" % time() # real sophisticated uid scheme.
    contentdom = getDOMImplementation().createDocument(None, "package", None)
    package = contentdom.documentElement

    package.setAttribute("version","2.0")
    package.setAttribute("xmlns","http://www.idpf.org/2007/opf")
    package.setAttribute("unique-identifier","epubmerge-id")
    metadata=newTag(contentdom,"metadata",
                    attrs={"xmlns:dc":"http://purl.org/dc/elements/1.1/",
                           "xmlns:opf":"http://www.idpf.org/2007/opf"})
    metadata.appendChild(newTag(contentdom,"dc:identifier",text=uniqueid,attrs={"id":"epubmerge-id"}))
    if( titleopt is None ):
        titleopt = booktitles[0]+" Anthology"
    metadata.appendChild(newTag(contentdom,"dc:title",text=titleopt))

    # If cmdline authors, use those instead of those collected from the epubs
    # (allauthors kept for TOC & description gen below.
    if( len(authoropts) > 1  ):
        useauthors=[authoropts]
    else:
        useauthors=allauthors

    usedauthors=dict()
    for authorlist in useauthors:
        for author in authorlist:
            if( author not in usedauthors ):
                usedauthors[author]=author
                metadata.appendChild(newTag(contentdom,"dc:creator",
                                            attrs={"opf:role":"aut"},
                                            text=author))

    metadata.appendChild(newTag(contentdom,"dc:contributor",text="epubmerge"))
    metadata.appendChild(newTag(contentdom,"dc:rights",text="Copyrights as per source stories"))

    for l in languages:
        metadata.appendChild(newTag(contentdom,"dc:language",text=l))

    if not descopt:
        # created now, but not filled in until TOC generation to save loops.
        description = newTag(contentdom,"dc:description",text="Anthology containing:\n")
    else:
        description = newTag(contentdom,"dc:description",text=descopt)
    metadata.appendChild(description)

    if source:
        metadata.appendChild(newTag(contentdom,"dc:identifier",
                                    attrs={"opf:scheme":"URL"},
                                    text=source))
        metadata.appendChild(newTag(contentdom,"dc:source",
                                    text=source))

    for tag in tags:
        metadata.appendChild(newTag(contentdom,"dc:subject",text=tag))

    package.appendChild(metadata)

    manifest = contentdom.createElement("manifest")
    package.appendChild(manifest)

    spine = newTag(contentdom,"spine",attrs={"toc":"ncx"})
    package.appendChild(spine)

    if coverjpgpath:
        # in case coverjpg isn't a jpg:
        coverext = 'jpg'
        covertype = 'image/jpeg'
        try:
            coverext = coverjpgpath.split('.')[-1].lower()
            covertype = imagetypes.get(coverext,covertype)
        except:
            pass
        logger.debug("coverjpgpath:%s coverext:%s covertype:%s"%(coverjpgpath,coverext,covertype))
        # <meta name="cover" content="cover.jpg"/>
        metadata.appendChild(newTag(contentdom,"meta",{"name":"cover",
                                                       "content":"coverimageid"}))
        guide = newTag(contentdom,"guide")
        guide.appendChild(newTag(contentdom,"reference",attrs={"type":"cover",
                                                   "title":"Cover",
                                                   "href":"cover.xhtml"}))
        package.appendChild(guide)

        manifest.appendChild(newTag(contentdom,"item",
                                    attrs={'id':"coverimageid",
                                           'href':"cover."+coverext,
                                           'media-type':covertype}))

        # Note that the id of the cover xhmtl *must* be 'cover'
        # for it to work on Nook.
        manifest.appendChild(newTag(contentdom,"item",
                                    attrs={'id':"cover",
                                           'href':"cover.xhtml",
                                           'media-type':"application/xhtml+xml"}))

        spine.appendChild(newTag(contentdom,"itemref",
                                 attrs={"idref":"cover",
                                        "linear":"yes"}))

    for item in items:
        # logger.debug("new item:%s %s %s"%item)
        (id,href,type)=item
        manifest.appendChild(newTag(contentdom,"item",
                                       attrs={'id':id,
                                              'href':href,
                                              'media-type':type}))

    for itemref in itemrefs:
        # logger.debug("itemref:%s"%itemref)
        spine.appendChild(newTag(contentdom,"itemref",
                                    attrs={"idref":itemref,
                                           "linear":"yes"}))

    ## create toc.ncx file
    tocncxdom = getDOMImplementation().createDocument(None, "ncx", None)
    ncx = tocncxdom.documentElement
    ncx.setAttribute("version","2005-1")
    ncx.setAttribute("xmlns","http://www.daisy.org/z3986/2005/ncx/")
    head = tocncxdom.createElement("head")
    ncx.appendChild(head)
    head.appendChild(newTag(tocncxdom,"meta",
                            attrs={"name":"dtb:uid", "content":uniqueid}))
    depthnode = newTag(tocncxdom,"meta",
                            attrs={"name":"dtb:depth", "content":"4"})
    head.appendChild(depthnode)
    head.appendChild(newTag(tocncxdom,"meta",
                            attrs={"name":"dtb:totalPageCount", "content":"0"}))
    head.appendChild(newTag(tocncxdom,"meta",
                            attrs={"name":"dtb:maxPageNumber", "content":"0"}))

    docTitle = tocncxdom.createElement("docTitle")
    docTitle.appendChild(newTag(tocncxdom,"text",text=titleopt))
    ncx.appendChild(docTitle)

    tocnavMap = tocncxdom.createElement("navMap")
    ncx.appendChild(tocnavMap)

    booknum=0

    printt("wrote initial metadata:%s"%(time()-t))
    t = time()

    for navmap in navmaps:
        depthnavpoints = navmap.getElementsByTagNameNS("*","navPoint") # for checking more than one TOC entry

        # logger.debug( [ x.toprettyxml() for x in navmap.childNodes ] )
        ## only gets top level TOC entries.  sub entries carried inside.
        navpoints = [ x for x in navmap.childNodes if isinstance(x,Element) and x.tagName=="navPoint" ]
        # logger.debug("len(navpoints):%s"%len(navpoints))
        # logger.debug( [ x.toprettyxml() for x in navpoints ] )
        newnav = None
        if titlenavpoints:
            newnav = newTag(tocncxdom,"navPoint",{"id":"book%03d"%booknum})
            navlabel = newTag(tocncxdom,"navLabel")
            newnav.appendChild(navlabel)
            # For purposes of TOC titling & desc, use first book author.  Skip adding author if only one.
            if len(usedauthors) > 1:
                title = booktitles[booknum]+" by "+allauthors[booknum][0]
            else:
                title = booktitles[booknum]

            navlabel.appendChild(newTag(tocncxdom,"text",text=title))
            # Find the first 'spine' item's content for the title navpoint.
            # Many epubs have the first chapter as first navpoint, so we can't just
            # copy that anymore.
            newnav.appendChild(newTag(tocncxdom,"content",
                                      {"src":firstitemhrefs[booknum]}))

            # logger.debug("newnav:%s"%newnav.toprettyxml())
            tocnavMap.appendChild(newnav)
            # logger.debug("tocnavMap:%s"%tocnavMap.toprettyxml())
        else:
            newnav = tocnavMap

        if not descopt and len(allauthors[booknum]) > 0:
            description.appendChild(contentdom.createTextNode(booktitles[booknum]+" by "+allauthors[booknum][0]+"\n"))

        # If only one TOC point(total, not top level), or if not
        # including title nav point, include sub book TOC entries.
        if originalnavpoints and (len(depthnavpoints) > 1 or not titlenavpoints):
            for navpoint in navpoints:
                # logger.debug("navpoint:%s"%navpoint.toprettyxml())
                newnav.appendChild(navpoint)
                navpoint.is_ffdl_epub = is_ffdl_epub[booknum]

        booknum=booknum+1;
        # end of navmaps loop.


    maxdepth = 0
    contentsrcs = {}
    removednodes = []
    ## Force strict ordering of playOrder, stripping out some.
    playorder=0
    # logger.debug("tocncxdom:%s"%tocncxdom.toprettyxml())
    for navpoint in tocncxdom.getElementsByTagNameNS("*","navPoint"):
        # logger.debug("navpoint:%s"%navpoint.toprettyxml())
        if navpoint in removednodes:
            continue
        # need content[src] to compare for dups.  epub wants dup srcs to have same playOrder.
        contentsrc = None
        for n in navpoint.childNodes:
            if isinstance(n,Element) and n.tagName == "content":
                contentsrc = n.getAttribute("src")
                # logger.debug("contentsrc: %s"%contentsrc)
                break

        if( contentsrc not in contentsrcs ):

            parent = navpoint.parentNode
            try:
                # if the epub was ever edited with Sigil, it changed
                # the id, but the file name is the same.
                if navpoint.is_ffdl_epub and \
                        ( navpoint.getAttribute("id").endswith('log_page') \
                              or contentsrc.endswith("log_page.xhtml") ):
                    logger.debug("Doing sibs 'filter' 1")
                    sibs = [ x for x in parent.childNodes if isinstance(x,Element) and x.tagName=="navPoint" ]
                    # if only logpage and one chapter, remove them from TOC and just show story.
                    if len(sibs) == 2:
                        parent.removeChild(navpoint)
                        logger.debug("Removing %s:"% sibs[0].getAttribute("playOrder"))
                        parent.removeChild(sibs[1])
                        removednodes.append(sibs[1])
            except:
                pass

            # New src, new number.
            contentsrcs[contentsrc] = navpoint.getAttribute("id")
            playorder += 1
            navpoint.setAttribute("playOrder","%d" % playorder)
            # logger.debug("playorder:%d:"%playorder)

            # need to know depth of deepest navpoint for <meta name="dtb:depth" content="2"/>
            npdepth = 1
            dp = navpoint.parentNode
            while dp and dp.tagName != "navMap":
                npdepth += 1
                dp = dp.parentNode

            if npdepth > maxdepth:
                maxdepth = npdepth
        else:
            # same content, look for ffdl and title_page and/or single chapter.

            # easier to just set it now, even if the node gets removed later.
            navpoint.setAttribute("playOrder","%d" % playorder)
            logger.debug("playorder:%d:"%playorder)

            parent = navpoint.parentNode
            try:
                # if the epub was ever edited with Sigil, it changed
                # the id, but the file name is the same.
                if navpoint.is_ffdl_epub and \
                        ( navpoint.getAttribute("id").endswith('title_page') \
                              or contentsrc.endswith("title_page.xhtml") ):
                    parent.removeChild(navpoint)
                    logger.debug("Doing sibs 'filter' 2")
                    sibs = [ x for x in parent.childNodes if isinstance(x,Element) and x.tagName=="navPoint" ]
                    # if only one chapter after removing title_page, remove it too.
                    if len(sibs) == 1:
                        logger.debug("Removing %s:"% sibs[0].getAttribute("playOrder"))
                        parent.removeChild(sibs[0])
                        removednodes.append(sibs[0])
            except:
                pass


    if flattentoc:
        maxdepth = 1
        # already have play order and pesky dup/single chapters
        # removed, just need to flatten.
        flattocnavMap = tocncxdom.createElement("navMap")
        for n in tocnavMap.getElementsByTagNameNS("*","navPoint"):
            flattocnavMap.appendChild(n)

        ncx.replaceChild(flattocnavMap,tocnavMap)

    printt("navmap/toc maddess:%s"%(time()-t))
    t = time()

    depthnode.setAttribute("content","%d"%maxdepth)

    ## content.opf written now due to description being filled in
    ## during TOC generation to save loops.
    contentxml = contentdom.toprettyxml(indent='   ',encoding='utf-8')
    # tweak for brain damaged Nook STR.  Nook insists on name before content.
    contentxml = contentxml.replace(ensure_binary('<meta content="coverimageid" name="cover"/>'),
                                    ensure_binary('<meta name="cover" content="coverimageid"/>'))
    outputepub.writestr("content.opf",contentxml)
    outputepub.writestr("toc.ncx",tocncxdom.toprettyxml(indent='   ',encoding='utf-8'))

    printt("wrote opf/ncx files:%s"%(time()-t))
    t = time()

    if coverjpgpath:
        # write, not write string.  Pulling from file.
        outputepub.write(coverjpgpath,"cover."+coverext)

        outputepub.writestr("cover.xhtml",'''
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"><head><title>Cover</title><style type="text/css" title="override_css">
@page {padding: 0pt; margin:0pt}
body { text-align: center; padding:0pt; margin: 0pt; }
div { margin: 0pt; padding: 0pt; }
</style></head><body><div>
<img src="cover.'''+coverext+'''" alt="cover"/>
</div></body></html>
''')

    # declares all the files created by Windows.  otherwise, when
    # it runs in appengine, windows unzips the files as 000 perms.
    for zf in outputepub.filelist:
        zf.create_system = 0
    outputepub.close()

    printt("closed outputepub:%s"%(time()-t))
    t = time()

    return (source,filecount)

def doUnMerge(inputio,outdir=None):
    epub = ZipFile(inputio, 'r') # works equally well with inputio as a path or a blob
    outputios = []

    ## Find the .opf file.
    container = epub.read("META-INF/container.xml")
    containerdom = parseString(container)
    rootfilenodelist = containerdom.getElementsByTagName("rootfile")
    rootfilename = rootfilenodelist[0].getAttribute("full-path")

    contentdom = parseString(epub.read(rootfilename))

    ## Save the path to the .opf file--hrefs inside it are relative to it.
    relpath = get_path_part(rootfilename)
    logger.debug("relpath:%s"%relpath)

    # spin through the manifest--only place there are item tags.
    # Correction--only place there *should* be item tags.  But
    # somebody found one that did.
    manifesttag=contentdom.getElementsByTagNameNS("*","manifest")[0]
    for item in manifesttag.getElementsByTagNameNS("*","item"):
        # look for our fake media-type for original rootfiles.
        if( item.getAttribute("media-type") == "origrootfile/xml" ):
            # found one, assume the dir containing it is a complete
            # original epub, do initial setup of epub.
            itemhref = normpath(relpath+unquote(item.getAttribute("href")))
            logger.debug("Found origrootfile:%s"%itemhref)
            curepubpath = re.sub(r'([^\d/]+/)+$','',get_path_part(itemhref))
            savehref = itemhref[len(curepubpath):]
            logger.debug("curepubpath:%s"%curepubpath)

            outputio = BytesIO()
            outputepub = ZipFile(outputio, "w", compression=ZIP_STORED, allowZip64=True)
            outputepub.debug = 3
            outputepub.writestr("mimetype", "application/epub+zip")
            outputepub.close()

            ## Re-open file for content.
            outputepub = ZipFile(outputio, "a", compression=ZIP_DEFLATED, allowZip64=True)
            outputepub.debug = 3
            ## Create META-INF/container.xml file.  The only thing it does is
            ## point to content.opf
            containerdom = getDOMImplementation().createDocument(None, "container", None)
            containertop = containerdom.documentElement
            containertop.setAttribute("version","1.0")
            containertop.setAttribute("xmlns","urn:oasis:names:tc:opendocument:xmlns:container")
            rootfiles = containerdom.createElement("rootfiles")
            containertop.appendChild(rootfiles)
            rootfiles.appendChild(newTag(containerdom,"rootfile",{"full-path":savehref,
                                                                  "media-type":"application/oebps-package+xml"}))
            outputepub.writestr("META-INF/container.xml",containerdom.toprettyxml(indent='   ',encoding='utf-8'))

            outputepub.writestr(savehref,epub.read(itemhref))

            for item2 in contentdom.getElementsByTagName("item"):
                item2href = normpath(relpath+unquote(item2.getAttribute("href")))
                if item2href.startswith(curepubpath) and item2href != itemhref:
                    save2href = item2href[len(curepubpath):]
                    logger.debug("Found %s -> %s"%(item2href,save2href))
                    outputepub.writestr(save2href,epub.read(item2href))

            # declares all the files created by Windows.  otherwise, when
            # it runs in appengine, windows unzips the files as 000 perms.
            for zf in outputepub.filelist:
                zf.create_system = 0
            outputepub.close()

            outputios.append(outputio)

    if outdir:
        outfilenames=[]
        for count,epubIO in enumerate(outputios):
            filename="%s/%d.epub"%(outdir,count)
            logger.debug("write %s"%filename)
            outstream = open(filename,"wb")
            outstream.write(epubIO.getvalue())
            outstream.close()
            outfilenames.append(filename)
        return outfilenames
    else:
        return outputios

def get_path_part(n):
    relpath = os.path.dirname(n)
    if( len(relpath) > 0 ):
        relpath=relpath+"/"
    return relpath


## Utility method for creating new tags.
def newTag(dom,name,attrs=None,text=None):
    tag = dom.createElement(name)
    if( attrs is not None ):
        for attr in attrs.keys():
            tag.setAttribute(attr,attrs[attr])
    if( text is not None ):
        tag.appendChild(dom.createTextNode(unicode(text)))
    return tag

def getText(nodelist):
    rc = []
    for node in nodelist:
        if node.nodeType == node.TEXT_NODE:
            rc.append(node.data)
    return ''.join(rc)

if __name__ == "__main__":
    main(sys.argv[1:])
    #doUnMerge(sys.argv[1],sys.argv[2])
