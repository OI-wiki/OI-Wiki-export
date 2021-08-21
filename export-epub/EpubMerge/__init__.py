#!/usr/bin/env python
# vim:fileencoding=UTF-8:ts=4:sw=4:sta:et:sts=4:ai
# -*- coding: utf-8 -*-
from __future__ import (unicode_literals, division, absolute_import,
                        print_function)

__license__   = 'GPL v3'
__copyright__ = '2020, Jim Miller'
__docformat__ = 'restructuredtext en'

# The class that all Interface Action plugin wrappers must inherit from
from calibre.customize import InterfaceActionBase

import sys, os
if sys.version_info >= (2, 7):
    import logging
    logger = logging.getLogger(__name__)
    loghandler=logging.StreamHandler()
    loghandler.setFormatter(logging.Formatter("EpubMerge: %(levelname)s: %(asctime)s: %(filename)s(%(lineno)d): %(message)s"))
    logger.addHandler(loghandler)

    from calibre.constants import DEBUG
    if os.environ.get('CALIBRE_WORKER', None) is not None or DEBUG:
        loghandler.setLevel(logging.DEBUG)
        logger.setLevel(logging.DEBUG)
    else:
        loghandler.setLevel(logging.CRITICAL)
        logger.setLevel(logging.CRITICAL)

# pulls in translation files for _() strings
try:
    load_translations()
except NameError:
    pass # load_translations() added in calibre 1.9

## Apparently the name for this class doesn't matter.
class EpubMergeBase(InterfaceActionBase):
    '''
    This class is a simple wrapper that provides information about the
    actual plugin class. The actual interface plugin class is called
    EpubMergePlugin and is defined in the epubmerge_plugin.py file, as
    specified in the actual_plugin field below.

    The reason for having two classes is that it allows the command line
    calibre utilities to run without needing to load the GUI libraries.
    '''
    name                = 'EpubMerge'
    description         = _('UI plugin to concatenate multiple epubs into one.')
    supported_platforms = ['windows', 'osx', 'linux']
    author              = 'Jim Miller'
    version             = (2, 11, 0)
    minimum_calibre_version = (3, 48, 0)

    #: This field defines the GUI plugin class that contains all the code
    #: that actually does something. Its format is module_path:class_name
    #: The specified class must be defined in the specified module.
    actual_plugin       = 'calibre_plugins.epubmerge.epubmerge_plugin:EpubMergePlugin'

    def is_customizable(self):
        '''
        This method must return True to enable customization via
        Preferences->Plugins
        '''
        return True

    def config_widget(self):
        '''
        Implement this method and :meth:`save_settings` in your plugin to
        use a custom configuration dialog.

        This method, if implemented, must return a QWidget. The widget can have
        an optional method validate() that takes no arguments and is called
        immediately after the user clicks OK. Changes are applied if and only
        if the method returns True.

        If for some reason you cannot perform the configuration at this time,
        return a tuple of two strings (message, details), these will be
        displayed as a warning dialog to the user and the process will be
        aborted.

        The base class implementation of this method raises NotImplementedError
        so by default no user configuration is possible.
        '''
        # It is important to put this import statement here rather than at the
        # top of the module as importing the config class will also cause the
        # GUI libraries to be loaded, which we do not want when using calibre
        # from the command line
        from calibre_plugins.epubmerge.config import ConfigWidget
        return ConfigWidget(self.actual_plugin_)

    def save_settings(self, config_widget):
        '''
        Save the settings specified by the user with config_widget.

        :param config_widget: The widget returned by :meth:`config_widget`.
        '''
        config_widget.save_settings()

        # Apply the changes
        ac = self.actual_plugin_
        if ac is not None:
            ac.apply_settings()

    def cli_main(self,argv):
        from calibre_plugins.epubmerge.epubmerge import main as epubmerge_main
        epubmerge_main(argv[1:],usage='%prog --run-plugin '+self.name+' --')
