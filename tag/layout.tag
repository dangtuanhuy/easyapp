<layout role="tabpanel" class="tab-pane" id="layout">
    <div class="row">
        <div class="col-sm-5 col-lg-4">
            <browse dir="{contentPath}"></browse>
        </div>
        <div class="col-sm-7 col-lg-8">
            <div class="row">
                <ol class="breadcrumb" style="margin-left: 5px; margin-bottom: 5px;">
                    <li><a class="pathName">{filePath}</a></li>
                    <div class="pull-right">
                        <div class="btn-group">
                            <button type="button" class="btn btn-default btn-xs">
                                <i class="fa fa-fw fa-undo"></i> Undo
                            </button>
                            <button type="button" class="btn btn-primary btn-xs">
                                <i class="fa fa-fw fa-save"></i> Save
                            </button>

                        </div>
                    </div>
                </ol>
                <code-editor id="{'layout-raw-editor'}" mode="{'jsx'}"></code-editor>
            </div>
        </div>
    </div>

    <script>
        var Path = require('path');
        var Fs = require('fs');

        var me = this;

        me.filePath = '';

        var FORM_START = '---json';
        var FORM_END = '---';
        function stripContentJson(content) {
            var start = content.indexOf(FORM_START);
            if (start == -1) return '';
            start += FORM_START.length;

            var end = content.indexOf(FORM_END, start);
            if (end == -1) return '';

            return content.substr(start, end - start).trim();
        }

        me.contentPath = Path.join(opts.dir, 'layout');

        me.on('mount', function () {
            setTimeout(function () {
                me.tags['code-editor'].setOption('mode', {name: 'handlebars', base: 'text/html'});
            }, 2000);

            // refresh codemirror editor khi tab duoc active
            $(me.root).find('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
                if (e.target.dataset.name === 'raw') {
                    me.tags['code-editor'].refresh();
                }
            })
        });

        me.openFile = function (filePath) {
            try {
                me.filePath = Path.basename(filePath);
                me.update();
                var fileContent = Fs.readFileSync(filePath).toString();
//                fileContent = stripContentJson(fileContent);

                me.tags['code-editor'].setValue(fileContent);
//                me.tags['form-editor'].parseForm(fileContent);
            } catch (ex) {
                console.log('content tab open file failed', ex);
            }
        };
    </script>
</layout>
