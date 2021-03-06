<file-list-flat>
    <div class="ui search fluid" style="padding-top: 6px;">
        <div class="ui icon input fluid">
            <input class="prompt" placeholder="enter keywords" type="text" onkeyup="{onFilterInput}">
            <i class="search icon"></i>
        </div>
    </div>
    <!--
    <div class="ui left icon fluid input">
        <input placeholder="" type="text" style="border: none" onkeyup="{onFilterInput}">
        <i class="filter icon"></i>
    </div>
    -->
    <div class="simplebar" style="overflow-x: hidden; padding: 0; margin: 0; height: calc(100% - 80px)">
        <div class="ui celled list">
            <div class="item" each="{item in filteredFiles}" onclick="{openFile}" data-path="{item.path}" data-content="{hideExt(item.name)}" data-html="{genContentTooltip(item.path)}">
                <div class="right floated content">
                    <label class="header">{getContentCategory(item.path)}</label>
                </div>
                <i class="{getFileIcon(item.name, item.path)}"></i>
                <div class="content">
                    <a class="truncate">{genDisplayName(item.name, item.path)}</a>
                </div>
            </div>
        </div>
    </div>

    <style scoped>
        .ui.celled.list > .item.active {
            background-color: #2185D0;
        }

        .ui.celled.list > .item.active > .content > a {
            color: white;
        }

        .octicon {
            display: table-cell;
            padding-right: 6px;
        }

        .octicon + div.content {
            display: table-cell;
        }

        .item {
            cursor: pointer;
        }

        .item:hover {
            background: #F9FAFB;
        }

    </style>

    <script>
        var me = this;
        me.files = [];
        me.filteredFiles = [];

        var $root = $(me.root);
        var curFilePath = '';

        me.isPartial = function (path) {
            return path.indexOf('layout/partial/') != -1;
        };

        var updateList = function () {
            me.update();
        };

        me.on('mount', function () {
            $(me.root.querySelector('.simplebar')).simplebar();
            $(me.root).find('.item').popup({
                position:   'right center',
                variation:  'inverted wide',
                lastResort: true,
                preserve:   false,
                delay:      {
                    show: 200,
                    hide: 0
                }
            });

            riot.event.on('contentMetaDataUpdated', updateList);
        });

        me.on('unmount', function () {
            riot.event.off('contentMetaDataUpdated', updateList);
        });

        function getCategoryBreadcrumb(category) {
            let parts = category.split('.');
            let ret = [];
            for (let i = 0; i < parts.length; i++) {
                let categoryName = parts.slice(0, i + 1).join('.');
                let meta = window.siteCategoryIndexes[categoryName];
                if (meta && meta.displayName)
                    ret.push(meta.displayName);
                else
                    ret.push(parts[i]);
            }

            return ret.join(' >> ');
        }

        me.genContentTooltip = function (contentPath) {
            if (me.opts.type !== 'content')
                return '';
            contentPath = contentPath.startsWith('content/') ? contentPath.slice(8) : contentPath;
            var metaData = window.siteContentIndexes[contentPath];
            if (!metaData || !metaData.category)
                return '';

            return `<div class='ui list'><div class='item'><div class='header'>${metaData.title}</div>${contentPath}<br>${getCategoryBreadcrumb(metaData.category)}</div></div>`;
        };

        me.getContentCategory = function (contentPath) {
            if (me.opts.type !== 'content')
                return '';

            contentPath = contentPath.startsWith('content/') ? contentPath.slice(8) : contentPath;
            var metaData = window.siteContentIndexes[contentPath];
            if (!metaData || !metaData.category)
                return '';
            var displayName = metaData.category.split('.').pop(); // last category name
            let meta = window.siteCategoryIndexes[metaData.category];
            if (meta && meta.displayName)
                displayName = meta.displayName;
            return displayName;
        };

        // TODO gen whole file block html thay vi` copy paste trung cac doan xu ly
        me.genDisplayName = function (name, path) {
            if (me.opts.type !== 'content')
                return me.getContentType(path) + me.hideExt(name);

            path = path.startsWith('content/') ? path.slice(8) : path;
            var metaData = window.siteContentIndexes[path];

            if (!metaData || !metaData.title) {
                return '';
            }

            return metaData.title;
        };

        me.getContentType = function (path) {
            if (path.indexOf('layout/partial/') != -1)
                return '[Partial] ';
            if (path.endsWith('.category.html'))
                return '[Category] ';
            if (path.endsWith('.tag.html'))
                return '[Tag] ';
            if (path.indexOf('content/metadata/category/') != -1)
                return '[Category] ';
            if (path.indexOf('content/metadata/tag/') != -1)
                return '[Tag] ';
            return '';
        };

        me.getFileIcon = function (name, path) {
            var ext = name.split('\.').pop().toLowerCase();
            switch (ext) {
                case 'html':
                    if (me.isPartial(path))
                        return 'octicon octicon-file-text';
                    else
                        return 'octicon octicon-file-code';
                case 'css':
                case 'js':
                    return 'octicon octicon-file-code';
                case 'json':
                    return 'octicon octicon-settings';
                case 'md':
                    return 'octicon octicon-markdown';
                default:
                    return 'octicon octicon-file-text';
            }
        };

        var fuzzySearch = function (needle, haystack) {
            var hLen = haystack.length;
            var nLen = needle.length;
            if (nLen > hLen || haystack === '') {
                return false;
            }

            if (nLen === hLen) {
                return needle === haystack;
            }

            needle = needle.toLowerCase();
            haystack = haystack.toLowerCase();

            outer: for (var i = 0, j = 0; i < nLen; i++) {
                var nch = needle.charCodeAt(i);
                if (nch === 32) continue;
                while (j < hLen) {
                    if (haystack.charCodeAt(j++) === nch) {
                        continue outer;
                    }
                }
                return false;
            }
            return true;
        };

        var delay = (function () {
            var timer = 0;
            return function (callback, ms) {
                clearTimeout(timer);
                timer = setTimeout(callback, ms);
            };
        })();

        var sortByExt = function (a, b) {
            if (a.path.startsWith('content/metadata/category'))
                return 1;

            if (a.path.startsWith('content/metadata/'))
                return 1;
//            return -1;
            return a.name > b.name;
        };

        var sortByName = function (a, b) {
            var val1 = a.name;
            var val2 = b.name;
            if (val1 == val2)
                return 0;
            if (val1 > val2)
                return 1;
            if (val1 < val2)
                return -1;
        };

        var sortLayoutFiles = function (files) {
            var categories = [];
            var tags = [];
            var partials = [];
            var others = [];

            files.forEach(function (file) {
                if (file.path.startsWith('layout/partial'))
                    partials.push(file);
                else if (file.path.endsWith('.category.html'))
                    categories.push(file);
                else if (file.path.endsWith('.tag.html'))
                    tags.push(file);
                else
                    others.push(file);
            });

            categories.sort();
            tags.sort();
            partials.sort();
            others.sort();

            return partials.concat(categories, tags, others);
        };

        var filterDeletedContent = function (files) {
            return files.filter(function (file) {
//                console.log('file.name', file.name);
                var metaData = window.siteContentIndexes[file.name];
                // TODO when support recursive use file.path as key to lookup metadata
                if (metaData && metaData.layout && metaData.layout === '404.html') {
                    return false;
                }
                return true;
            });
        };

        var sortContentFiles = function (files) {
            var categories = [];
            var tags = [];
            var contents = [];
            var metadataList = [];

            files.forEach(function (file) {
                if (file.path.startsWith('content/metadata/category/')) {
                    categories.push(file);
                } else if (file.path.startsWith('content/metadata/tag/')) {
                    tags.push(file);
                } else if (file.path.startsWith('content/metadata/')) {
                    metadataList.push(file);
                } else {
                    contents.push(file);
                }
            });

            categories.sort();
            metadataList.sort();
            contents.sort();
            return metadataList.concat(categories, tags, contents);
        };

        me.hideExt = function (name) {
            var parts = name.split('.');
            if (parts.length > 1)
                parts.pop();

            if (name.endsWith('.category.html') || name.endsWith('.tag.html'))
                parts.pop();

            return parts.join('.');
        };

        me.loadFiles = function (files) {
            me.clear();
            if (me.opts.type == 'layout') {
                files = sortLayoutFiles(files);
            } else if (me.opts.type == 'content') {
                files = filterDeletedContent(files);
                files = sortContentFiles(files);
            } else if (me.opts.type == 'meta') {
                files = sortContentFiles(files);
            } else {
                files = files.sort(sortByName);
            }

            me.files = files;
            me.filteredFiles = files;
            me.update();
        };

        me.openFile = function (e) {
            // console.log('open file', e);
            var filePath = e.item.item.path; // riot magic !
            if (filePath === me.curFilePath) return;
            me.curFilePath = filePath;
            $root.find('.item').removeClass('active');
            $(e.srcElement).closest('.item').addClass('active');

            riot.event.trigger('fileActivated', me.opts.type, filePath);
            me.trigger('openFile', filePath);
        };

        me.activeFile = function (filePath) {
            var elm = $root.find('[data-path="' + filePath + '"]');
            $root.find('.item').removeClass('active');
            $(elm).addClass('active');
        };

        me.clearActive = function () {
            $root.find('.item').removeClass('active');
            me.curFilePath = '';
        };

        me.filter = function (e) {
            var needle = e.target.value;
            var filtered = [];
            for (var file of me.files) {
                if (fuzzySearch(needle, file.name)) {
                    filtered.push(file);
                }
            }

            me.filteredFiles = filtered;
            me.update();
        };

        me.filterEx = function (e) {
            var needle = e.target.value;
            var filterByList = [];
            var filename;

            // extract filterBy neu co
            const metaFilterRegex = /:([^:\s]+)\s+([^\t\s]+)/gmu;
            var matches;
            while ((matches = metaFilterRegex.exec(needle)) !== null) {
                // This is necessary to avoid infinite loops with zero-width matches
                if (matches.index === metaFilterRegex.lastIndex) {
                    metaFilterRegex.lastIndex++;
                }
                if (matches.length === 3) {
                    needle = needle.replace(matches[0], ''); // remove from needed
                    filterByList.push({
                        key:   matches[1].trim(),
                        value: matches[2].trim()
                    });
                }
            }

            var filtered = [];
            var hayStack = {};

            // filter by file name first
            needle = needle.trim();

            // CHEAT for default search title
            if (needle !== '') {
                filterByList.push({
                    key:   'title',
                    value: needle
                });
            }
//            if (needle !== '') {
//                for (filename in window.siteContentIndexes) {
//                    if (!window.siteContentIndexes.hasOwnProperty(filename)) continue;
//                    if (fuzzySearch(needle, filename)) {
//                        hayStack[filename] = window.siteContentIndexes[filename];
//                    }
//                }
//            } else {
            // had to copy
            for (filename in window.siteContentIndexes) {
                if (!window.siteContentIndexes.hasOwnProperty(filename)) continue;
                hayStack[filename] = window.siteContentIndexes[filename];
            }
//            }

            // filter by metadata
            filterByList.forEach(filterBy => {
                for (filename in hayStack) {
                    if (!hayStack.hasOwnProperty(filename)) continue;
                    var lhs = filterBy.value;
                    var rhs = hayStack[filename][filterBy.key];
                    if (rhs === undefined || rhs === null || typeof(rhs) !== 'string') continue;

                    var ret = fuzzySearch(lhs, rhs);
                    if (ret === false) {
                        delete hayStack[filename];
                    }
                }
            });


            // convert hayStack to array of object name-path
            for (var file of me.files) {
                var contentPath = file.path.startsWith('content/') ? file.path.slice(8) : file.path;
                if (hayStack[contentPath]) {
                    filtered.push(file);
                }
            }

            me.filteredFiles = filtered;
            me.update();
        };

        me.onFilterInput = function (e) {
            delay(function () {
                if (me.opts.type == 'content') {
                    me.filterEx(e)
                } else {
                    me.filter(e)
                }
            }, 100);
        };

        me.clear = function () {
            me.filteredFiles = [];
            me.files = [];
            me.update();
        };
    </script>
</file-list-flat>
