#!/usr/bin/env python
# vim:fileencoding=UTF-8:ts=4:sw=4:sta:et:sts=4:ai
from __future__ import (unicode_literals, division, absolute_import,
                        print_function)

__license__   = 'GPL v3'
__copyright__ = '2020, Jim Miller'
__docformat__ = 'restructuredtext en'

import logging
logger = logging.getLogger(__name__)

import time, os
from datetime import datetime
from io import BytesIO
from functools import partial

import six

try:
    from PyQt5.Qt import (QMenu)
except ImportError as e:
    from PyQt4.Qt import (QMenu)

from calibre.ptempfile import PersistentTemporaryFile, PersistentTemporaryDirectory, remove_dir
from calibre.ebooks.metadata import MetaInformation
from calibre.ebooks.metadata.meta import set_metadata, metadata_from_formats
from calibre.gui2 import error_dialog
from calibre.gui2 import question_dialog
from calibre.gui2.dialogs.confirm_delete import confirm
from calibre.constants import config_dir as calibre_config_dir

# The class that all interface action plugins must inherit from
from calibre.gui2.actions import InterfaceAction

# pulls in translation files for _() strings
try:
    load_translations()
except NameError:
    pass # load_translations() added in calibre 1.9

from calibre_plugins.epubmerge.common_utils import (set_plugin_icon_resources, get_icon, create_menu_action_unique )

from calibre_plugins.epubmerge.config import (prefs, permitted_values)

from calibre_plugins.epubmerge.epubmerge import doMerge, doUnMerge

from calibre_plugins.epubmerge.dialogs import (
    LoopProgressDialog, OrderEPUBsDialog, AddOverDiscardDialog
    )

PLUGIN_ICONS = ['images/icon.png','images/unmerge.png']

class EpubMergePlugin(InterfaceAction):

    name = 'EpubMerge'

    # Declare the main action associated with this plugin
    # The keyboard shortcut can be None if you dont want to use a keyboard
    # shortcut. Remember that currently calibre has no central management for
    # keyboard shortcuts, so try to use an unusual/unused shortcut.
    # (text, icon_path, tooltip, keyboard shortcut)
    # icon_path isn't in the zip--icon loaded below.
    action_spec = (_('EpubMerge'), None,
                   _('Merge multiple EPUBs into one in a new book.'), ())
    # None for keyboard shortcut doesn't allow shortcut.  () does, there just isn't one yet

    action_type = 'global'
    # make button menu drop down only
    #popup_type = QToolButton.InstantPopup

    # disable when not in library. (main,carda,cardb)
    def location_selected(self, loc):
        enabled = loc == 'library'
        self.qaction.setEnabled(enabled)
        self.menuless_qaction.setEnabled(enabled)
        for action in self.menu.actions():
            action.setEnabled(enabled)

    def genesis(self):

        # This method is called once per plugin, do initial setup here

        base = self.interface_action_base_plugin
        self.version = base.name+" v%d.%d.%d"%base.version

        # Read the plugin icons and store for potential sharing with the config widget
        icon_resources = self.load_resources(PLUGIN_ICONS)
        set_plugin_icon_resources(self.name, icon_resources)

        # Set the icon for this interface action
        # The get_icons function is a builtin function defined for all your
        # plugin code. It loads icons from the plugin zip file. It returns
        # QIcon objects, if you want the actual data, use the analogous
        # get_resources builtin function.

        # Note that if you are loading more than one icon, for performance, you
        # should pass a list of names to get_icons. In this case, get_icons
        # will return a dictionary mapping names to QIcons. Names that
        # are not found in the zip file will result in null QIcons.
        icon = get_icon('images/icon.png')

        # The qaction is automatically created from the action_spec defined
        # above
        self.qaction.setIcon(icon)

        # Call function when plugin triggered.
        self.qaction.triggered.connect(self.plugin_button)

        # Assign our menu to this action
        self.menu = QMenu()
        self.qaction.setMenu(self.menu)

    def initialization_complete(self):
        # setup menu.
        self.merge_action = self.create_menu_item_ex(self.menu, _('&Merge Epubs'), image='images/icon.png',
                                                     unique_name=_('&Merge Epubs'),
                                                     triggered=self.plugin_button )

        self.unmerge_action = self.create_menu_item_ex(self.menu, _('&UnMerge Epubs'), image='images/unmerge.png',
                                                       unique_name=_('&UnMerge Epubs'),
                                                       triggered=self.unmerge )


        # logger.debug("platform.system():%s"%platform.system())
        # logger.debug("platform.mac_ver()[0]:%s"%platform.mac_ver()[0])
        if not self.check_macmenuhack(): # not platform.mac_ver()[0]: # Some macs crash on these menu items for unknown reasons.
            do_user_config = self.interface_action_base_plugin.do_user_config
            self.menu.addSeparator()
            self.config_action = self.create_menu_item_ex(self.menu, _('&Configure Plugin'),
                                                          image= 'config.png',
                                                          unique_name=_('Configure EpubMerge'),
                                                          shortcut_name=_('Configure EpubMerge'),
                                                          triggered=partial(do_user_config,parent=self.gui))


        self.gui.keyboard.finalize()

    def create_menu_item_ex(self, parent_menu, menu_text, image=None, tooltip=None,
                           shortcut=None, triggered=None, is_checked=None, shortcut_name=None,
                           unique_name=None):
        #logger.debug("create_menu_item_ex before %s"%menu_text)
        ac = create_menu_action_unique(self, parent_menu, menu_text, image, tooltip,
                                       shortcut, triggered, is_checked, shortcut_name, unique_name)
        #logger.debug("create_menu_item_ex after %s"%menu_text)
        return ac

    ## Kludgey, yes, but with the real configuration inside the
    ## library now, how else would a user be able to change this
    ## setting if it's crashing calibre?
    def check_macmenuhack(self):
        try:
            return self.macmenuhack
        except:
            file_path = os.path.join(calibre_config_dir,
                                     *("plugins/fanficfare_macmenuhack.txt".split('/')))
            file_path = os.path.abspath(file_path)
            logger.debug("macmenuhack file_path:%s"%file_path)
            self.macmenuhack = os.access(file_path, os.F_OK)
            return self.macmenuhack

    def do_unmerge(self, *args, **kwargs):
        '''Also called by FanFicFare plugin.'''
        return doUnMerge(*args, **kwargs)

    def do_merge(self, *args, **kwargs):
        '''
        Also called by FanFicFare plugin.  Note that no epub2 vs epub3
        check is done here--FFF(optionally) outputs epub3, but
        includes back-compat files that will work for EpubMerge.
        '''
        return doMerge(*args, **kwargs)

    def unmerge(self):
        db=self.gui.current_db
        applyall = False
        state = 'add'
        for book_id in self.gui.library_view.get_selected_ids():
            unmerge_mi = db.get_metadata(book_id,index_is_id=True)
            if db.has_format(book_id,'EPUB',index_is_id=True):
                epub = BytesIO(db.format(book_id,'EPUB',index_is_id=True))
            else:
                d = error_dialog(self.gui,
                                 _('Cannot UnMerge Non-Epubs'),
                                 unmerge_mi.title + '<br>'+_('To UnMerge the source must be Epub(s) created by EpubMerge with Keep UnMerge Metadata enabled.'),
                                 show_copy_button=False)
                d.exec_()
                continue

            tdir = PersistentTemporaryDirectory(prefix='epubmerge_')
            logger.debug("tdir:%s"%tdir)
            outfilenames = self.do_unmerge(epub,tdir)
            if not outfilenames:
                d = error_dialog(self.gui,
                                 _('No UnMerge data found'),
                                 unmerge_mi.title + '<br>'+_('To UnMerge the source must be Epub(s) created by EpubMerge with Keep UnMerge Metadata enabled.'),
                                 show_copy_button=False)
                d.exec_()
                remove_dir(tdir)
                continue

            added_list=[]
            updated_list=[]
            for formats in db.find_books_in_directory(tdir, False):
                #logger.debug("formats:%s"%formats)
                mi = metadata_from_formats(formats)
                #logger.debug("mi:%s"%mi)

                identicalbooks = db.find_identical_books(mi)
                if identicalbooks:
                    if len(identicalbooks) == 1:
                        text = unmerge_mi.title + '<br>'+_("You already have a book <i>%s</i> by <i>%s</i>.  You may Add a new book of the same title, Overwrite the Epub in the existing book, or Discard this Epub.")%(mi.title,", ".join(mi.authors))
                        over=True
                    else:
                        text = unmerge_mi.title + '<br>'+_("You already have more than one book <i>%s</i> by <i>%s</i>.  You may Add a new book of the same title, or Discard this Epub.")%(mi.title,", ".join(mi.authors))
                        over=False

                    #logger.debug("applyall:%s over:%s state:%s"%(applyall,over, state))
                    if applyall and ( over or state in ('add', 'discard') ):
                        # use previous state.
                        pass
                    else:
                        d = AddOverDiscardDialog(self.gui,self.qaction.icon(),text,over=over)
                        d.exec_()
                        state=d.state
                        applyall=d.get_applyall()

                if state == 'add' or len(identicalbooks) == 0:
                    book_id = db.create_book_entry(mi,
                                                   add_duplicates=True)
                    added_list.append(book_id)
                elif state == 'discard':
                    continue
                elif state == 'over':
                    book_id = identicalbooks.pop()

                db.add_format_with_hooks(book_id,
                                         'EPUB',
                                         formats[0], index_is_id=True)
                updated_list.append(book_id)

            if len(added_list):
                self.gui.library_view.model().books_added(len(added_list))

            if len(updated_list):
                self.gui.library_view.model().refresh_ids(updated_list)

            remove_dir(tdir)

    def plugin_button(self):
        self.t = time.time()

        if len(self.gui.library_view.get_selected_ids()) < 2:
            d = error_dialog(self.gui,
                             _('Cannot Merge Epubs'),
                             _('Less than 2 books selected.'),
                             show_copy_button=False)
            d.exec_()
        else:
            db=self.gui.current_db

            logger.debug("1:%s"%(time.time()-self.t))
            self.t = time.time()

            book_list = [ self._convert_id_to_book(x, good=False) for x in self.gui.library_view.get_selected_ids() ]
            # book_ids = self.gui.library_view.get_selected_ids()

            # put all temp epubs in a temp dir for convenience of
            # deleting and not needing to keep track of temp input
            # epubs vs using library epub.
            tdir = PersistentTemporaryDirectory(prefix='epubmerge_')
            LoopProgressDialog(self.gui,
                               book_list,
                               partial(self._populate_book_from_calibre_id, db=self.gui.current_db, tdir=tdir),
                               partial(self._start_merge,tdir=tdir),
                               init_label=_("Collecting EPUBs for merger..."),
                               win_title=_("Get EPUBs for merge"),
                               status_prefix=_("EPUBs collected"))

    def _start_merge(self,book_list,tdir=None):
        db=self.gui.current_db
        self.previous = self.gui.library_view.currentIndex()
        # if any bad, bail.
        bad_list = [ x for x in book_list if not x['good'] ]
        if len(bad_list) > 0:
            d = error_dialog(self.gui,
                             _('Cannot Merge Epubs'),
                             _('%s books failed.')%len(bad_list),
                             det_msg='\n'.join( [ x['error'] for x in bad_list ]))
            d.exec_()
        else:
            d = OrderEPUBsDialog(self.gui,
                                 _('Order EPUBs to Merge'),
                                 prefs,
                                 self.qaction.icon(),
                                 book_list,
                                 )
            d.exec_()
            if d.result() != d.Accepted:
                return

            book_list = d.get_books()

            logger.debug("2:%s"%(time.time()-self.t))
            self.t = time.time()

            deftitle = "%s %s" % (book_list[0]['title'],prefs['mergeword'])
            mi = MetaInformation(deftitle,["Temp Author"])

            # if all same series, use series for name.  But only if all.
            serieslist = [ x['series'] for x in book_list if x['series'] != None ]
            if len(serieslist) == len(book_list):
                mi.title = serieslist[0]
                for sr in serieslist:
                    if mi.title != sr:
                        mi.title = deftitle;
                        break

            # logger.debug("======================= mi.title:\n%s\n========================="%mi.title)

            mi.authors = list()
            authorslists = [ x['authors'] for x in book_list ]
            for l in authorslists:
                for a in l:
                    if a not in mi.authors:
                        mi.authors.append(a)
            #mi.authors = [item for sublist in authorslists for item in sublist]

            # logger.debug("======================= mi.authors:\n%s\n========================="%mi.authors)

            #mi.author_sort = ' & '.join([ x['author_sort'] for x in book_list ])

            # logger.debug("======================= mi.author_sort:\n%s\n========================="%mi.author_sort)

            # set publisher if all from same publisher.
            publishers = set([ x['publisher'] for x in book_list ])
            if len(publishers) == 1:
                mi.publisher = publishers.pop()

            # logger.debug("======================= mi.publisher:\n%s\n========================="%mi.publisher)

            tagslists = [ x['tags'] for x in book_list ]
            mi.tags = [item for sublist in tagslists for item in sublist]
            mi.tags.extend(prefs['mergetags'].split(','))

            # logger.debug("======================= mergetags:\n%s\n========================="%prefs['mergetags'])
            # logger.debug("======================= m.tags:\n%s\n========================="%mi.tags)

            languageslists = [ x['languages'] for x in book_list ]
            mi.languages = [item for sublist in languageslists for item in sublist]

            mi.series = ''
            if prefs['firstseries'] and book_list[0]['series']:
                mi.series = book_list[0]['series']
                mi.series_index = book_list[0]['series_index']

            # ======================= make book comments =========================

            if len(mi.authors) > 1:
                booktitle = lambda x : _("%s by %s") % (x['title'],' & '.join(x['authors']))
            else:
                booktitle = lambda x : x['title']

            mi.comments = ("<p>"+_("%s containing:")+"</p>") % prefs['mergeword']

            if prefs['includecomments']:
                def bookcomments(x):
                    if x['comments']:
                        return '<p><b>%s</b></p>%s'%(booktitle(x),x['comments'])
                    else:
                        return '<b>%s</b><br/>'%booktitle(x)

                mi.comments += ('<div class="mergedbook">' +
                                '<hr></div><div class="mergedbook">'.join([ bookcomments(x) for x in book_list]) +
                                '</div>')
            else:
                mi.comments += '<br/>'.join( [ booktitle(x) for x in book_list ] )

            # ======================= make book entry =========================

            book_id = db.create_book_entry(mi,
                                           add_duplicates=True)

            # set default cover to same as first book
            coverdata = db.cover(book_list[0]['calibre_id'],index_is_id=True)
            if coverdata:
                db.set_cover(book_id, coverdata)

            # ======================= custom columns ===================

            logger.debug("3:%s"%(time.time()-self.t))
            self.t = time.time()

            # have to get custom from db for each book.
            idslist = [ x['calibre_id'] for x in book_list ]

            custom_columns = self.gui.library_view.model().custom_columns
            for col, action in six.iteritems(prefs['custom_cols']):
                #logger.debug("col: %s action: %s"%(col,action))

                if col not in custom_columns:
                    logger.debug("%s not an existing column, skipping."%col)
                    continue

                coldef = custom_columns[col]
                #logger.debug("coldef:%s"%coldef)

                if action not in permitted_values[coldef['datatype']]:
                    logger.debug("%s not a valid column type for %s, skipping."%(col,action))
                    continue

                label = coldef['label']

                found = False
                value = None
                idx = None
                if action == 'first':
                    idx = 0

                if action == 'last':
                    idx = -1

                if action in ['first','last']:
                    value = db.get_custom(idslist[idx], label=label, index_is_id=True)
                    if coldef['datatype'] == 'series' and value != None:
                        # get the number-in-series, too.
                        value = "%s [%s]"%(value, db.get_custom_extra(idslist[idx], label=label, index_is_id=True))
                    found = True

                if action in ('add','average','averageall'):
                    value = 0.0
                    count = 0
                    for bid in idslist:
                        try:
                            value += db.get_custom(bid, label=label, index_is_id=True)
                            found = True
                            # only count ones with values unless averageall
                            count += 1
                        except:
                            # if not set, it's None and fails.
                            # only count ones with values unless averageall
                            if action == 'averageall':
                                count += 1

                    if found and action in ('average','averageall'):
                        value = value / count

                    if coldef['datatype'] == 'int':
                        value += 0.5 # so int rounds instead of truncs.

                if action == 'and':
                    value = True
                    for bid in idslist:
                        try:
                            value = value and db.get_custom(bid, label=label, index_is_id=True)
                            found = True
                        except:
                            # if not set, it's None and fails.
                            pass

                if action == 'or':
                    value = False
                    for bid in idslist:
                        try:
                            value = value or db.get_custom(bid, label=label, index_is_id=True)
                            found = True
                        except:
                            # if not set, it's None and fails.
                            pass

                if action == 'newest':
                    value = None
                    for bid in idslist:
                        try:
                            ivalue = db.get_custom(bid, label=label, index_is_id=True)
                            if not value or  ivalue > value:
                                value = ivalue
                                found = True
                        except:
                            # if not set, it's None and fails.
                            pass

                if action == 'oldest':
                    value = None
                    for bid in idslist:
                        try:
                            ivalue = db.get_custom(bid, label=label, index_is_id=True)
                            if not value or  ivalue < value:
                                value = ivalue
                                found = True
                        except:
                            # if not set, it's None and fails.
                            pass

                if action == 'union':
                    if not coldef['is_multiple']:
                        action = 'concat'
                    else:
                        value = set()
                        for bid in idslist:
                            try:
                                value = value.union(db.get_custom(bid, label=label, index_is_id=True))
                                found = True
                            except:
                                # if not set, it's None and fails.
                                pass

                if action == 'concat':
                    value = ""
                    for bid in idslist:
                        try:
                            value = value + ' ' + db.get_custom(bid, label=label, index_is_id=True)
                            found = True
                        except:
                            # if not set, it's None and fails.
                            pass
                    value = value.strip()

                if action == 'now':
                    value = datetime.now()
                    found = True
                    logger.debug("now: %s"%value)

                if found and value != None:
                    logger.debug("value: %s"%value)
                    db.set_custom(book_id,value,label=label,commit=False)

            db.commit()

            logger.debug("4:%s"%(time.time()-self.t))
            self.t = time.time()

            self.gui.library_view.model().books_added(1)
            self.gui.library_view.select_rows([book_id])

            logger.debug("5:%s"%(time.time()-self.t))
            self.t = time.time()

            confirm('\n'+_('''The book for the new Merged EPUB has been created and default metadata filled in.

However, the EPUB will *not* be created until after you've reviewed, edited, and closed the metadata dialog that follows.'''),
                    'epubmerge_created_now_edit_again',
                    self.gui,
                    title=_("EpubMerge"),
                    show_cancel_button=False)

            self.gui.iactions['Edit Metadata'].edit_metadata(False)

            logger.debug("5:%s"%(time.time()-self.t))
            self.t = time.time()
            self.gui.tags_view.recount()

            totalsize = sum([ x['epub_size'] for x in book_list ])
            logger.debug("merging %s EPUBs totaling %s"%(len(book_list),gethumanreadable(totalsize)))
            confirm('\n'+_('''EpubMerge will be done in a Background job.  The merged EPUB will not appear in the Library until finished.

You are merging %s EPUBs totaling %s.''')%(len(book_list),gethumanreadable(totalsize)),
                    'epubmerge_background_merge_again',
                    self.gui,
                    title=_("EpubMerge"),
                    show_cancel_button=False)

            # if len(book_list) > 100 or totalsize > 5*1024*1024:
            #     confirm('\n'+_('''You're merging %s EPUBs totaling %s.  Calibre will be locked until the merge is finished.''')%(len(book_list),gethumanreadable(totalsize)),
            #             'epubmerge_edited_now_merge_again',
            #             self.gui)

            self.gui.status_bar.show_message(_('Merging %s EPUBs...')%len(book_list), 60000)

            mi = db.get_metadata(book_id,index_is_id=True)

            mergedepub = PersistentTemporaryFile(prefix="output_",
                                                 suffix='.epub',
                                                 dir=tdir)
            epubstomerge = [ x['epub'] for x in book_list ]
            epubtitles = {}
            for x in book_list:
                # save titles indexed by epub for reporting from BG
                epubtitles[x['epub']]=_("%s by %s") % (x['title'],' & '.join(x['authors']))

            coverjpgpath = None
            if mi.has_cover:
                # grab the path to the real image.
                coverjpgpath = os.path.join(db.library_path, db.path(book_id, index_is_id=True), 'cover.jpg')


            func = 'arbitrary_n'
            cpus = self.gui.job_manager.server.pool_size
            args = ['calibre_plugins.epubmerge.jobs',
                    'do_merge_bg',
                    ({'book_id':book_id,
                      'book_count':len(book_list),
                      'tdir':tdir,
                      'outputepubfn':mergedepub.name,
                      'inputepubfns':epubstomerge, # already .name'ed
                      'epubtitles':epubtitles, # for reporting
                      'authoropts':mi.authors,
                      'titleopt':mi.title,
                      'descopt':mi.comments,
                      'tags':mi.tags,
                      'languages':mi.languages,
                      'titlenavpoints':prefs['titlenavpoints'],
                      'originalnavpoints':prefs['originalnavpoints'],
                      'flattentoc':prefs['flattentoc'],
                      'printtimes':True,
                      'coverjpgpath':coverjpgpath,
                      'keepmetadatafiles':prefs['keepmeta']
                      },
                     cpus)]
            desc = _('EpubMerge: %s')%mi.title
            job = self.gui.job_manager.run_job(
                self.Dispatcher(self.merge_done),
                func, args=args,
                description=desc)

            self.gui.jobs_pointer.start()
            self.gui.status_bar.show_message(_('Starting EpubMerge'),3000)

    def merge_done(self,job):
        db=self.gui.current_db
        logger.info("merge_done(%s,%s)"%(job.failed,job.args))
        args = job.args[2][0]
        if job.failed:
            # self.gui.job_exception(job, dialog_title=_('EpubMerge Failed'))
            if question_dialog(self.gui, _('Remove Failed Anthology Book?'),'''
                          <h3>%s</h3>
                          <p>%s</p>
                          <p><b>%s</b></p>
                          <p>%s</p>
                          <p>%s</p>'''%(
                    _("Remove Failed Anthology Book?"),
                    _("EpubMerge failed, no new EPUB was created; see the background job details for any error messages."),
                    _("Do you want to delete the empty book EpubMerge created?"),
                    _("Click '<b>Yes</b>' to remove empty book from Libary,"),
                    _("Click '<b>No</b>' to leave it in Library.")),
                               show_copy_button=False):
                self.gui.iactions['Remove Books'].do_library_delete([args['book_id']])
            return
        outputepubfn = args['outputepubfn']
        book_id = args['book_id']
        book_count = args['book_count']
        logger.debug("6:%s"%(time.time()-self.t))
        logger.debug(_("Merge finished, output in:\n%s")%outputepubfn)
        self.t = time.time()
        db.add_format_with_hooks(book_id,
                                 'EPUB',
                                 outputepubfn, index_is_id=True)

        logger.debug("7:%s"%(time.time()-self.t))
        self.t = time.time()

        # clean up temp files.
        remove_dir(args['tdir'])

        self.gui.status_bar.show_message(_('Finished merging %s EPUBs.')%book_count, 3000)
        self.gui.library_view.model().refresh_ids([book_id])
        self.gui.tags_view.recount()
        current = self.gui.library_view.currentIndex()
        self.gui.library_view.model().current_changed(current, self.previous)
            #self.gui.iactions['View'].view_book(False)
        if self.gui.cover_flow:
            self.gui.cover_flow.dataChanged()
        confirm('\n'+_('''EpubMerge has finished. The new EPUB has been added to the book previously created.'''),
                'epubmerge_finished_again',
                self.gui,
                title=_("EpubMerge"),
                show_cancel_button=False)

    def apply_settings(self):
        # No need to do anything with perfs here, but we could.
        prefs

    def _convert_id_to_book(self, idval, good=True):
        book = {}
        book['good'] = good
        book['calibre_id'] = idval
        book['title'] = _('Unknown')
        book['author'] = _('Unknown')
        book['author_sort'] = _('Unknown')
        book['error'] = ''
        book['comments'] = ''

        return book

    def _populate_book_from_calibre_id(self, book, db=None, tdir=None):
        mi = db.get_metadata(book['calibre_id'], index_is_id=True)
        #book = {}
        book['good'] = True
        book['calibre_id'] = mi.id
        book['title'] = mi.title
        book['authors'] = mi.authors
        book['author_sort'] = mi.author_sort
        book['tags'] = mi.tags
        book['series'] = mi.series
        book['comments'] = mi.comments
        book['publisher'] = mi.publisher
        book['pubdate'] = mi.pubdate
        if book['series']:
            book['series_index'] = mi.series_index
        else:
            book['series_index'] = None
        book['languages'] = mi.languages
        book['error'] = ''
        if db.has_format(mi.id,'EPUB',index_is_id=True):
            if prefs['keepmeta']:
                # save calibre metadata inside epub if keeping unmerge
                # data.
                tmp = PersistentTemporaryFile(prefix='input_%s_'%mi.id,
                                              suffix='.epub',
                                              dir=tdir)
                db.copy_format_to(mi.id,'EPUB',tmp,index_is_id=True)
                set_metadata(tmp, mi, stream_type='epub')
                book['epub'] = tmp.name
            else:
                # don't need metadata, use epub directly
                book['epub'] = db.format_abspath(mi.id,'EPUB',index_is_id=True)
            book['epub_size'] = os.stat(book['epub']).st_size
        else:
            book['good'] = False;
            book['error'] = _("%s by %s doesn't have an EPUB.")%(mi.title,', '.join(mi.authors))

def gethumanreadable(size,precision=1):
    suffixes=['B','KB','MB','GB','TB']
    suffixIndex = 0
    while size > 1024:
        suffixIndex += 1 #increment the index of the suffix
        size = size/1024.0 #apply the division
    return "%.*f%s"%(precision,size,suffixes[suffixIndex])
