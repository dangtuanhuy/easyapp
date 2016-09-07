<file-list-flat>
    <div class="input-group">
        <span class="input-group-addon" style="border-bottom-left-radius: 0;"><i class="fa fa-fw fa-filter"></i></span>
        <input type="text" class="form-control" style="border-bottom-right-radius: 0;" placeholder="Enter keywords to search" onkeyup="{onFilterInput}">
    </div>
    <div class="list-group" style="overflow: auto; padding: 0; margin: 0; height: calc(100vh - 130px)">
        <a href="#" each="{filteredFiles}" class="list-group-item truncate" title="{hideExt(name)}" data-path="{path}" onclick="{openFile}" style="{}">
            <span style="margin-right: 10px; margin-left: -5px;" class={getFileIcon(name, path)}></span> {getContentType(path)}{hideExt(name)}
        </a>
    </div>
    <script>
        var me = this;
        me.event = riot.observable();
        me.files = [];
        me.filteredFiles = [];

        var $root = $(me.root);
        var curFilePath = '';

        me.isPartial = function (path) {
            return path.indexOf('layout/partial/') != -1;
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
            if (nLen > hLen) {
                return false;
            }
            if (nLen === hLen) {
                return needle === haystack;
            }
            outer: for (var i = 0, j = 0; i < nLen; i++) {
                var nch = needle.charCodeAt(i);
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
            } else if (me.opts.type == 'metadata') {
                files = sortContentFiles(files);
            } else {
                files = files.sort(sortByName);
            }

            me.files = files;
            me.filteredFiles = files;
            me.update();
        };

        me.openFile = function (e) {
            var filePath = e.target.dataset.path;
            if (filePath === me.curFilePath) return;
            me.curFilePath = filePath;
            $root.find('.list-group-item').removeClass('active');
            $(e.currentTarget).addClass('active');
            console.log('TRIGGER fileActivated', filePath);
            riot.api.trigger('fileActivated', me.opts.type, filePath);
            me.event.trigger('openFile', filePath);
        };

        me.activeFile = function (filePath) {
//            console.log("filePath", filePath);
//            console.log("query '[data-path=\"' + filePath + '\"]'");
            var elm = $root.find('[data-path="' + filePath + '"]');
            $root.find('.list-group-item').removeClass('active');
//            console.log('elm', elm);
            $(elm).addClass('active');
        };

        me.clearActive = function () {
            $root.find('.list-group-item').removeClass('active');
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

        me.onFilterInput = function (e) {
            delay(function () {
                me.filter(e)
            }, 100);
        };

        me.clear = function () {
            me.filteredFiles = [];
            me.files = [];
            me.update();
        };
    </script>
</file-list-flat>
