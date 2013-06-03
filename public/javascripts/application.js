// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require_tree .
(function ($) {

    /* update the upload file list */
    $.formatVideoInfo = $.fn.formatVideoInfo = function (v) {
        // 格式 | 分辨率 | 片长 | 大小
        return v['video_format'] + " | " + v['frame_size'] + " | " + v['duration'] + " | " + $.formatFileSize(v['data_size'])
    }

    $.formatFileSize = $.fn.formatFileSize = function (size) {
        var s1 = Math.round(size / 1024)
        var result = ""
        if (s1 == 0)
            result = size + "B"
        var s2 = Math.round(s1 / 1000)
        if (s2 == 0)
            result = s1 + "KB"
        else
            result = s2 + "MB"
        return result
    }

    $.formatIndexNum = $.fn.formatIndexNum = function (num) {
        if (num >= 0 && num < 10)
            return "0" + num
        else
            return num
    }

    $.updateIndexNum = $.fn.updateIndexNum = function (qe, k) {
        var i = 1
        $(qe).find("." + k).each(function () {
            $(this).find('span').html($.formatIndexNum(i++))
        })
    }

    $.bindHover = $.fn.bindHover = function () {
        $(".need-hover").hover(
            function () {
                $(this).addClass('ui-state-hover')
            }, function () {
                $(this).removeClass('ui-state-hover')
            }
        )
    }
    //.find(".select-all-hook"), panel.find("tbody")
    $.bindCheckboxAll = $.fn.bindCheckboxAll = function (hook_block) {
        var item_hooks = hook_block.find("tbody")
        var all_hook = hook_block.find("input[class='select-all-hook']")
        all_hook.click(function () {
            if ($(this).is(':checked')) {
                item_hooks.find("input[type=checkbox]").each(function () {
                    if ($(this).attr('disabled') == undefined || $(this).attr('disabled') == false)
                        $(this).attr("checked", true)

                })
            } else {
                item_hooks.find("input[type=checkbox]").each(function () {
                    if ($(this).attr('disabled') == undefined || $(this).attr('disabled') == false)
                        $(this).attr("checked", false)
                })
            }
            $(this).attr('checked', $(this).is(':checked'))
        })
        item_hooks.find("input[type=checkbox]").each(function () {
            $(this).click(function () {
                $(this).attr('checked', $(this).is(':checked'))
                if (all_hook.is(':checked'))
                    all_hook.attr('checked', false)
            })
        })
    }


    $.simpleFileTree = $.fn.simpleFileTree = function (o, proc) {
        // Defaults
        if (!o) var o = {};
        if (o.root == undefined) o.root = '/';
        if (o.fileExt == undefined) o.fileExt = null;
        if (o.script == undefined) o.script = '';
        if (o.folderEvent == undefined) o.folderEvent = 'click';
        if (o.expandSpeed == undefined) o.expandSpeed = 500;
        if (o.collapseSpeed == undefined) o.collapseSpeed = 500;
        if (o.multiFolder == undefined) o.multiFolder = true;
        if (o.loadMessage == undefined) o.loadMessage = 'Loading...';

        $(this).each(function () {
            function showTree(c, t) {
                var curBlock = $(c)
                var spanBlock = curBlock.find("span:first")
                spanBlock.addClass('wait');
                // before method is post should have auth_token
                $.getJSON(o.script, { dir:t, fileExt:o.fileExt}, function (data) {
                    $(".jqueryFileTree.start").remove();
                    curBlock.find('.start').html('');
                    var content = "<ul class=\"jqueryFileTree\" style=\"display: none;\">"
                    if (data['flag']) {
                        for (var v in data['dirs']) {
                            content += "<li class='directory collapsed'>\
                                <span class='dir'><a href='#' rel='" + data['dirs'][v].path + "'>" + data['dirs'][v].name + "</a></span>\
                             </li>"
                        }
                        for (var v in data['files']) {
                            content += "<li class='file'> \
                                <span class='file ext_" + data['files'][v].ext + "'><a href='#' rel='" + data['files'][v].path + "'>" + data['files'][v].name + "</a></span>\
                             </li>"
                        }
                    } else {
                        content = "<ul><li><span>" + data['msg'] + "</span></li></ul>"
                    }
                    content += "</ul>"
                    spanBlock.removeClass('wait')
                    curBlock.append(content);

                    if (o.root == t)
                        curBlock.find('UL:hidden').show();
                    else
                        curBlock.find('UL:hidden').slideDown({
                            duration:o.expandSpeed,
                            easing:o.expandEasing
                        });
                    bindTree(curBlock);
                });
            }

            function bindTree(t) {
                $(t).find('SPAN A').each(function () {
                    $(this).unbind().bind('click', function () {
//                        console.log($(this).attr('rel'))
                        proc($(this).attr('rel'));
                        var curBlock = $(this).parent().parent()
                        if (curBlock.hasClass('directory')) {
                            if (curBlock.hasClass('collapsed')) {
                                if( !o.multiFolder ) {
                                    $(this).parent().removeClass('exp')
                                    curBlock.parent().find('UL').slideUp({ duration: o.collapseSpeed, easing: o.collapseEasing });
                                    curBlock.parent().find('LI.directory').removeClass('expanded').addClass('collapsed');
                                }
                                curBlock.find('ul').each(function () {
                                    $(this).remove()
                                }); // cleanup
                                showTree(curBlock, $(this).attr('rel'));
                                curBlock.removeClass('collapsed').addClass('expanded');
                                $(this).parent().addClass('exp')
                            } else {
                                // Collapse
                                curBlock.find('ul').slideUp({ duration:o.collapseSpeed, easing:o.collapseEasing });
                                $(this).parent().removeClass('exp')
                                curBlock.removeClass('expanded').addClass('collapsed');
                            }
                        }
                        return false;
                    });
                });

            }

            // Loading message
            $(this).html('<ul class="jqueryFileTree start"><li><span>' + o.loadMessage + '</span></li></ul>');
            // Get the initial file list
            showTree($(this), o.root);
        });
    }

    $.showVideoInfoFromUpload = $.fn.showVideoInfoFromUpload = function (vId) {
        $.getJSON('upload/video_info', {id:vId}, function (result) {
//            console.log(result)
            $("#video_info .filename").html(result['filename'])
            if (result['flag']) {
                $("#video_info .content").html(result['content'].replace(/[\r\n|\r|\n]/gi, "<br/>"))
            } else {
                $("#video_info .content").html(result['msg'])
            }
        })
        $("#video_info").dialog("open")
    }


})(jQuery);
