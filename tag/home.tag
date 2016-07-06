<home>
    <new-content-dialog></new-content-dialog>
    <new-layout-dialog></new-layout-dialog>
    <progress-dialog></progress-dialog>
    <github-init-dialog></github-init-dialog>
    <nav class="navbar navbar-default">
        <br/>
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-4 pull-left">
                    <a href="#" onclick="{newContent}" class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        <i class="fa fa-fw fa-plus"></i> Add Content
                    </a>
                    <a href="#" onclick="{newLayout}" class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        <i class="fa fa-fw fa-plus"></i> Add Layout
                    </a>
                </div>
                <div class="pull-right">
                    <div class="btn-group" data-toggle="buttons">
                        <a class="btn btn-default btn-sm" href="#watch-view" data-toggle="tab" role="tab" onclick="{openWatchView}">
                            <input type="radio" name="options"><i class="fa fa-fw fa-eye"></i>Preview
                        </a>
                    </div>
                    <div class="btn-group" data-toggle="buttons">
                        <a href="#" class="btn btn-default navbar-btn btn-sm" onclick="{syncToGitHub}" title="Sync project to GitHub">
                            <i class="fa fa-fw fa-github"></i> Sync
                        </a>
                        <a href="#" class="btn btn-default navbar-btn btn-sm" onclick="{deployToGitHub}" title="Deploy to gh-pages">
                            Deploy
                        </a>
                        <a class="btn btn-default navbar-btn btn-sm dropdown-toggle" href="#" onclick="{showGitHubSetting}" title="Init github setting">
                            Init
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </nav>

    <div class="container-fluid">
        <div class="row">
            <div class="col-md-4">
                <side-bar site_name={opts.siteName}></side-bar>
            </div>

            <div class="col-md-8">
                <div class="btn-group" data-toggle="buttons">
                    <a class=" btn btn-default navbar-btn btn-sm {currentFileTitle.endsWith('.md') ? '' : 'disabled'}" href="#content-view" data-toggle="tab" role="tab" onclick="{openContentTab}">
                        <input type="radio" name="options"><i class="fa fa-fw fa-newspaper-o"></i> Content
                    </a>
                    <a class="btn btn-default navbar-btn btn-sm" href="#code-view" data-toggle="tab" role="tab" onclick="{openRawContentTab}">
                        <input type="radio" name="options">Raw
                    </a>
                    <a class="btn btn-default navbar-btn btn-sm {currentFileTitle.endsWith('.md') ? '' : 'disabled'}" href="#layout-view" data-toggle="tab" role="tab" onclick="{openLayoutTab}">
                        <input type="radio" name="options"><i class="fa fa-fw fa-code"></i> Layout
                    </a>
                    <a class="btn btn-default navbar-btn btn-sm {currentFileTitle.endsWith('.md') ? '' : 'disabled'}" href="#config-view" data-toggle="tab" role="tab" onclick="{openConfigTab}">
                        <input type="radio" name="options"><i class="fa fa-fw fa-cog"></i> Config
                    </a>
                </div>
                <div class="pull-right">
                    <div class="btn-group" data-toggle="buttons">
                        <a class="btn btn-danger navbar-btn btn-sm" href="#" onclick="{deleteFile}">
                            <i class="fa fa-fw fa-remove"></i>Delete
                        </a>
                        <a class="btn btn-primary navbar-btn btn-sm" onclick="{save}"><i class="fa fa-save"></i> Save</a>
                    </div>
                </div>
                <!-- EDITOR PANEL -->
                <div class="panel panel-default" hide="{curTab === ''}">
                    <div class="panel-heading panel-heading-sm">
                        <breadcrumb site_name="{opts.siteName}"></breadcrumb>
                    </div>
                    <div class="panel-body">
                        <div class="tab-content">
                            <content-view id="content-view" role="tabpanel" class="tab-pane"></content-view>
                            <code-editor id="code-view" role="tabpanel" class="tab-pane"></code-editor>
                            <code-editor id="layout-view" role="tabpanel" class="tab-pane"></code-editor>
                            <config-view id="config-view" role="tabpanel" class="tab-pane"></config-view>
                            <watch-view id="watch-view" site_name="{siteName}" role="tabpanel" class="tab-pane"></watch-view>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        var me = this;
        me.contentView = null;
        me.configView = null;
        me.layoutView = null;
        me.codeView = null;
        me.watchView = null;
        me.curTab = '';
        me.currentFilePath = '';
        me.currentLayout = '';
        me.currentFileTitle = '';
        me.siteName = me.opts.siteName;

        me.on('mount', function () {
//            riot.mount('side-bar', {siteName: opts.siteName});
//            riot.mount('breadcrumb', {path: opts.siteName});
            // open index.md file
            setTimeout(function () {
//                me.openFile('content/index.md');
//                me.tags['side-bar'].activeFile('content/index.md');
            }, 1000);
        });

        function HideAllTab() {
            $(me.root).find('a[role="tab"]').removeClass('active');
        }

        function ShowTab(name) {
            me.curTab = name;
            var elm = $(me.root).find('a[href="#' + name + '"]');
            elm.tab('show');
            elm.addClass('active');
        }

        function UnmountAll() {
            if (me.contentView) me.contentView.unmount(true);
            if (me.configView) me.configView.unmount(true);
            if (me.layoutView) me.layoutView.unmount(true);
            if (me.codeView) me.codeView.unmount(true);
        }

        function getFileContent(filePath) {
            var fileContent = BackEnd.readFile(me.opts.siteName, filePath).trim();
            if (fileContent === null) return;
            // split content thanh meta va markdown
            return SplitContentFile(fileContent);
        }

        me.openLayoutTab = function () {
            HideAllTab();
            me.currentFileTitle = me.currentFilePath.split(/[/\\]/).pop();
//            me.currentLayout = me.currentFileTitle;
            console.log('openLayoutTab, me.currentFileTitle', me.currentFileTitle);
            me.update();
            console.log('get layout file', me.opts.siteName, me.currentLayout);
            var fileContent = BackEnd.getLayoutFile(me.opts.siteName, me.currentLayout);
            me.tags['code-editor'][1].value(fileContent);
            me.tags['code-editor'][1].setOption('readOnly', false);
            ShowTab('layout-view');
        };

        me.openAssetFile = function (filePath) {
            console.log('openAssetFile', filePath);
            me.currentFilePath = filePath;
            me.openRawContentTab({mode: 'auto'});
            me.update();
        };

        me.openContentTab = function () {
            try {
                HideAllTab();
                me.currentFileTitle = me.currentFilePath.split(/[/\\]/).pop();
//                console.log('me.currentFileTitle', me.currentFileTitle);
                me.update();

//            var content = getFileContent(me.currentFilePath);
                var content = BackEnd.getContentFile(me.opts.siteName, me.currentFilePath);
                if (!content || !content.metaData || !content.metaData.layout) {
//                    console.log('content missing meta or layout attribute');
                    me.tags['content-view'].reset();
//                return;
                } else {
                    me.currentLayout = content.metaData.layout;
                    var contentConfig = BackEnd.getConfigFile(me.opts.siteName, me.currentFilePath, content.metaData.layout);
//                    console.log('content', content);
                    me.tags['content-view'].setContent(content, contentConfig);
                }

                ShowTab('content-view');
            } catch (ex) {
                bootbox.alert('Open content failed, error ' + ex.message, function () {
                });
                me.openRawContentTab({
                    readOnly: false,
                    mode:     'json-frontmatter'
                });
            }
        };

        me.openConfigTab = function () {
            me.currentFileTitle = me.currentFilePath.split(/[/\\/]/).pop();
//            console.log('me.currentFileTitle', me.currentFileTitle);
            HideAllTab();

            var content = BackEnd.getContentFile(me.opts.siteName, me.currentFilePath);
            if (!content.metaData.layout) {
                alert('content missing layout attribute');
                return;
            }

            var contentConfig = BackEnd.getConfigFile(me.opts.siteName, me.currentFilePath, content.metaData.layout);

            me.tags['config-view'].loadContentConfig(contentConfig);
            ShowTab('config-view');
        };

        me.openRawContentTab = function (options) {
            console.log('openRawContentTab', options);
            me.currentFileTitle = me.currentFilePath.split(/[/\\]/).pop();
            me.tags['breadcrumb'].setPath(me.currentFilePath);
            options = options || {};
            HideAllTab();

            var rawStr = BackEnd.getRawContentFile(me.opts.siteName, me.currentFilePath);
            var contentCodeEditor = me.tags['code-editor'][0];
            contentCodeEditor.value(rawStr);

            contentCodeEditor.setOption('mode', 'json-frontmatter');
            for (var key in options) {
                if (!options.hasOwnProperty(key)) continue;
                contentCodeEditor.setOption(key, options[key]);
            }
            ShowTab('code-view');
        };

        me.openFile = function (filePath) {
//            console.log('home openFile', filePath);
            me.tags['breadcrumb'].setPath(filePath);
            me.currentFilePath = filePath;
            HideAllTab();

            if (filePath.endsWith('.md')) {
                me.openContentTab();
            } else if (filePath.endsWith('.config.json')) {
                me.openConfigTab();
            } else if (filePath.endsWith('.html')) {
                console.log(me.currentFilePath.split(/[/\\]/));
                me.currentLayout = me.currentFilePath.split(/[/\\]/);
                me.currentLayout.shift();
                me.currentLayout = me.currentLayout.join('/');
                me.openLayoutTab();
            } else if (filePath.endsWith('.json')) {
                me.openRawContentTab();
            }
            me.update();
        };

        me.save = function () {
//            var curTabHref = $(me.root).find('[role="presentation"].active>a').attr('href');
            switch (me.curTab) {
                case 'content-view':
                    var content = me.tags['content-view'].getContent();
                    BackEnd.saveContentFile(me.opts.siteName, me.currentFilePath, content.metaData, content.markdownData);
                    break;
                case 'code-view':
                    var rawContent = me.tags['code-editor'][0].value();
                    BackEnd.saveRawContentFile(me.opts.siteName, me.currentFilePath, rawContent);
                    break;
                case 'layout-view':
                    var layoutContent = me.tags['code-editor'][1].value();
                    BackEnd.saveLayoutFile(me.opts.siteName, me.currentLayout, layoutContent);
                    break;
                case 'config-view':
                    var contentConfig = me.tags['config-view'].getContentConfig();
                    BackEnd.saveConfigFile(me.opts.siteName, me.currentLayout, JSON.stringify(contentConfig, null, 4));
                    break;
            }
        };

        me.deleteFile = function () {
//            var curTabHref = $(me.root).find('[role="presentation"].active>a').attr('href');
//            console.log('delete file', me.curTab);
            switch (me.curTab) {
                case 'content-view':
                case 'code-view':
//                    console.log('delete file content-view');
                    var contentFilePath = me.currentFilePath;
                    if (contentFilePath.startsWith('content')) {
                        var parts = contentFilePath.split(/[\\\/]/);
                        parts.shift();
                        contentFilePath = parts.join('/');
                    }
//                    console.log('contentFilePath', contentFilePath);
                    bootbox.confirm({
                        title:    'Delete',
                        message:  `Are you sure you want to delete content "${contentFilePath}" ?`,
                        buttons:  {
                            'cancel':  {
                                label:     'Cancel',
                                className: 'btn-default'
                            },
                            'confirm': {
                                label:     'Delete',
                                className: 'btn-danger'
                            }
                        },
                        callback: function (result) {
                            if (result) {
                                BackEnd.deleteContentFile(me.opts.siteName, contentFilePath);
                                me.tags['side-bar'].reloadContentFileTab(me.opts.siteName); // reload sidebar file list
                                // hide rightCol
                                me.curTab = '';
                                me.tags['breadcrumb'].setPath('');
                                me.update();
                            }
                        }
                    });
                    break;
                case 'layout-view':
                    console.log('TODO delete layout', me.currentLayout);

                    break;
                case 'config-view':
                    console.log('TODO delete config', me.currentFilePath);
                    break;
            }
        };

        me.newLayout = function () {
//            console.log('newLayout');
            me.tags['new-layout-dialog'].show();
        };

        me.newContent = function () {
//            console.log('newContent');
            var layoutList = BackEnd.getLayoutList(me.siteName);
            console.log('layoutList', layoutList);
            me.tags['new-content-dialog'].updateLayoutList(layoutList);
            me.tags['new-content-dialog'].show();
        };

        riot.api.on('addLayout', function (layoutFileName) {
            try {
                var newFile = BackEnd.newLayoutFile(me.siteName, layoutFileName);
                console.log('trigger closeNewContentDialog');
                riot.api.trigger('closeNewLayoutDialog');
            } catch (ex) {
                console.log('addLayout', ex);
                bootbox.alert('create layout failed, error ' + ex.message);
            }
        });

        riot.api.on('addContent', function (layoutFileName, contentTitle, contentFileName, isFrontPage) {
            try {
                var newFile = BackEnd.newContentFile(me.siteName, layoutFileName, contentTitle, contentFileName, isFrontPage);
                var newContentFilePath = newFile.path;
                // reload sidebar file list
                me.tags['side-bar'].reloadContentFileTab(me.opts.siteName);
                riot.api.trigger('closeNewContentDialog');
                console.log('open file', newContentFilePath);
                me.openFile(newContentFilePath);
                //me.tags['side-bar'].activeFile(newContentFilePath);
            } catch (ex) {
                console.log('addContent', ex);
                bootbox.alert('create content failed, error ' + ex.message);
            }
        });

        me.deployToGitHub = function () {
            me.tags['progress-dialog'].show('Deploy to GitHub');
            BackEnd.gitPushGhPages(me.siteName, me.tags['progress-dialog'].appendText).then(function () {
                me.tags['progress-dialog'].enableClose();
            }).catch(function (err) {
                console.log(err);
                me.tags['progress-dialog'].enableClose();
            });
        };

        me.syncToGitHub = function () {
            me.tags['progress-dialog'].show('Sync to GitHub');
            BackEnd.gitPushGitHub(me.siteName, me.tags['progress-dialog'].appendText).then(function () {
                me.tags['progress-dialog'].enableClose();
            }).catch(function (err) {
                console.log(err);
                me.tags['progress-dialog'].enableClose();
            });
        };

        me.showGitHubSetting = function () {
            me.tags['github-init-dialog'].show();
            me.tags['github-init-dialog'].event.one('save', function (info) {
                me.tags['github-init-dialog'].hide();
                var repoUrl = 'https://' + info.username + ':' + info.password + '@' + (info.url.split('https://')[1]);
                console.log('repoUrl', repoUrl);
                me.tags['progress-dialog'].show('Init GitHub Setting');
                BackEnd.gitInitSite(me.siteName, repoUrl, me.tags['progress-dialog'].appendText).then(function () {
                    me.tags['progress-dialog'].enableClose();
                }).catch(function (err) {
                    console.log(err);
                    me.tags['progress-dialog'].enableClose();
                });
            });
        };

    </script>
</home>
