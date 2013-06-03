/**
 * Created with JetBrains RubyMine.
 * User: liangfan
 * Date: 12-11-22
 * Time: 上午2:20
 * To change this template use File | Settings | File Templates.
 */

(function ($) {
    /* transcode the video*/
    $.parseParams = $.fn.parseParams = function () {
        var p = $("#params_setting")
        return {
            filename: p.find('[name=filename]').val(),
            path: p.find('[name=path]').val(),
            video_format: p.find('[name=video_format]').val(),
            vcodec: p.find('[name=vcodec]').val(),
            frame_size: p.find('[name=frame_size]').val(),
            aspect: p.find('[name=aspect]').val(),
            fps: p.find('[name=fps]').val(),
            bitrate: p.find('[name=bitrate]').val(),
            acodec: p.find('[name=acodec]').val(),
            ar: p.find('[name=ar]').val(),
            ab: p.find('[name=ab]').val(),
            ac: p.find('[name=ac]').val()
        };
    }

    $.parseParams2 = $.fn.parseParams2 = function (params, new_params) {
        if (new_params.filename)
            params.filename = new_params.filename
        if (new_params.path)
            params.path = new_params.path
        if (new_params.video_format)
            params.video_format = new_params.video_format
        if (new_params.vcodec)
            params.vcodec = new_params.vcodec
        if (new_params.frame_size)
            params.frame_size = new_params.frame_size
        if (new_params.aspect)
            params.aspect = new_params.aspect
        if (new_params.fps)
            params.fps = new_params.fps
        if (new_params.bitrate)
            params.bitrate = new_params.bitrate
        if (new_params.acodec)
            params.acodec = new_params.acodec
        if (new_params.ar)
            params.ar = new_params.ar
        if (new_params.ab)
            params.ab = new_params.ab
        if (new_params.ac)
            params.ac = new_params.ac

//        console.log(params)
        return params
    }

    $.formatParams = $.fn.formatParams = function (tar_params, src_params) {
        var frame_size = tar_params.frame_size
        if (frame_size == "")
            frame_size = src_params.frame_size
        return tar_params.video_format + " " + tar_params.vcodec + " " + frame_size + " " + tar_params.bitrate + "kb " + tar_params.acodec + " " + tar_params.ab + "kb"
    }

    $.updateList = $.fn.updateList = function (flistBlock) {
        var videos = {} //{id1:{source:xxx,original:xxx}, id2:{source:xxx,target:xxx}...}
        $.getJSON("upload/list", {}, function (result) {
            if (result['flag'] == true) {
                var data = result['data']
                if (data.length == 0)
                    flistBlock.html("没有上传的视频文件")
                else {
                    flistBlock.html("")
                    var i = 1
                    for (var a in data) {
                        var orig = data[a]
                        videos[orig.id] = orig
                        var ytd = $("<tr/>").attr("class", "video-" + ['id'])
                        ytd.append($('<td/>').attr("class", "item-index").append($('<input>').attr("type", "checkbox").attr("class", "checkbox-item-hook").attr('checked', true).val(orig.id)).append($('<span/>').attr("class", "index-hook").html(0)))
                            .append($('<td/>').attr("class", "filename").html($('<input/>').attr('disabled', true).attr('value', orig.filename).attr('title', orig.filename)))
                            .append($('<td/>').attr("class", "info").html($.formatVideoInfo(orig)))
                            .append($('<td/>').attr('class', 'others')
                                .append($("<a/>").attr("href", "javascript:$.showVideoInfoFromUpload('" + orig.id + "')").attr('title', '详细信息').attr('class', 'ui-state-default ui-corner-all need-hover').append($('<span/>').attr('class', 'ui-icon ui-icon-info')))
                            )
                        flistBlock.append(ytd)
                    }
                    $.updateIndexNum(flistBlock, "item-index")
                    $.bindCheckboxAll(flistBlock.parent())
                    $.bindHover()
                }
            }
        })
        return videos
    }

    $.updateTransList = $.fn.updateTransList = function (queueBlock, doneBlock) {
        var transQueue = {} // {id1:{fileID:xxx, original:xxx, target:xxx}, id2:{fileID:xxx, original:xxx, target:xxx},...}
        var doneQueue = {}
        $.getJSON('transcode/list', {}, function (result) {
            var defaultMediaParams = $.parseParams()
            var trans_index = 0
            var done_index = 0
//            var transQueue = {} // {id1:{fileID:xxx, original:xxx, target:xxx}, id2:{fileID:xxx, original:xxx, target:xxx},...}
            if (result['flag'] == true) {
//                console.log(result['data']['prepare'])
                for (var d in result['data']['prepare']) {

                    var sour = result['data']['prepare'][d].original
                    var targ = $.extend(true, {}, defaultMediaParams)
                    var tar_resp = result['data']['prepare'][d].target
                    var fileID = 'PRE_TRANS_' + (trans_index++)
                    targ.id = tar_resp.id
                    targ.gsv_number = tar_resp.gsv_number
                    targ.status = tar_resp.status
                    targ.filename = 'trans-' + sour.filename
                    transQueue[targ.id] = {fileID: fileID, original: sour, target: targ}

                    var ytd = $("<tr/>").attr("id", fileID)
                    ytd.append($('<td/>').attr("class", "item-index").append($('<input>').attr("type", "checkbox").attr("class", "checkbox-item-hook").attr('value', targ.id)).append($('<span/>').attr("class", "index-hook")))
                        .append($('<td/>').attr("class", "status").html(targ.status))
                        .append($('<td/>').attr("class", "filename").html("<p>N1:<input disabled value='" + sour.filename + "." + sour.video_format + "'+title='" + sour.filename + "." + sour.video_format + "'/></p><p>N2:<input disabled class='target-filename' value='" + targ.filename + "' title='" + targ.filename + "'/>"))
                        .append($('<td/>').attr("class", "data-size").html($.formatFileSize(sour.data_size)))
                        .append($('<td/>').attr("class", "video-format").html(targ.video_format))
                        .append($('<td/>').attr("class", "path").html("<input disabled value='" + targ.path + "' title='" + targ.path + "'/>"))
                        .append($('<td/>').attr('class', 'others').html($("<a/>").attr("href", "javascript:$.showVideoInfo('" + sour.id + "','0')").attr('title', '源信息').attr('class', 'ui-state-default ui-corner-all need-hover').append($('<span/>').attr('class', 'ui-icon ui-icon-info'))
                            .after($('<a/>').attr("href", "javascript:$('#params_setting').val('" + targ.id + "','0').dialog('open')").attr('title', '设置').attr('class', 'cancel ui-state-default ui-corner-all need-hover').append($('<span/>').attr('class', 'ui-icon ui-icon-wrench')))
                        ))
//                        .after($('<a/>').attr('title', '删除').attr('class', 'cancel ui-state-default ui-corner-all need-hover').append($('<span/>').attr('class', 'ui-icon ui-icon-trash')))
                    queueBlock.append(ytd)
                }

                for (var i in result['data']['done']) {
                    var vInfo = result['data']['done'][i]
                    var fileID = 'DONE_TRANS_' + (done_index++)
                    doneQueue[vInfo.id] = {fileID: fileID, data: vInfo}
                    if (vInfo.complete_time == 'undefined' || vInfo.complete_time == "")
                        vInfo.complete_time = "没有记录"
                    var ytd = $("<tr/>").attr("id", fileID)
                    ytd.append($('<td/>').attr("class", "item-index").append($('<input>').attr("type", "checkbox").attr("class", "checkbox-item-hook").val(vInfo.id)).append($('<span/>').attr("class", "index-hook").html(0)))
                        .append($('<td/>').attr("class", "filename").html("<input disabled value='" + vInfo.filename + "'+title='" + vInfo.filename + "'/>"))
                        .append($('<td/>').attr("class", "video-format").html(vInfo.video_format))
                        .append($('<td/>').attr("class", "frame-size").html(vInfo.frame_size))
                        .append($('<td/>').attr("class", "data-size").html($.formatFileSize(vInfo.data_size)))
                        .append($('<td/>').attr("class", "done-time").html("<input disabled value='" + vInfo.complete_time + "' title='" + vInfo.complete_time + "'/>"))
                        .append($('<td/>').attr("class", "path").html("<input disabled value='" + vInfo.path + "' title='" + vInfo.path + "'/>"))
                        .append($('<td/>').attr('class', 'others')
                            .append($("<a/>").attr("href", "transcode/download/" + vInfo.id).attr('title', '下载').attr('class', 'ui-state-default ui-corner-all need-hover').append($('<span/>').attr('class', 'ui-icon ui-icon-arrowthick-1-s'))
                                .after($("<a/>").attr("href", "javascript:$.showVideoInfo('" + vInfo.id + "','1')").attr('title', '详细信息').attr('class', 'ui-state-default ui-corner-all need-hover').append($('<span/>').attr('class', 'ui-icon ui-icon-info')))))
//                        .after($('<a/>').attr("href", "javascript:void(0)").attr('title', '删除').attr('class', 'cancel ui-state-default ui-corner-all need-hover').append($('<span/>').attr('class', 'ui-icon ui-icon-wrench')))
                    doneBlock.append(ytd)
                }
                $.updateIndexNum(queueBlock, "item-index")
                $.bindCheckboxAll(queueBlock.parent())
                $.updateIndexNum(doneBlock, "item-index")
                $.bindCheckboxAll(doneBlock.parent())
                $.bindHover()
            }

        })
        return {transQueue: transQueue, doneQueue: doneQueue}
    }

    $.updateTransItem = $.fn.updateTransItem = function (vId, queue) {
        var doneBlock=$("#trans_done_list")
        $.getJSON('transcode/' + vId, {}, function (result) {
            var f_ID = "DONE_TRANS_NEW_" + vId
            var ytd = $("<tr/>").attr("id", f_ID)
            var vInfo = result.data
            queue[vId] = {data: vInfo, fileID: f_ID}
            ytd.append($('<td/>').attr("class", "item-index").append($('<input>').attr("type", "checkbox").attr("class", "checkbox-item-hook").val(vInfo.id)).append($('<span/>').attr("class", "index-hook").html(0)))
                .append($('<td/>').attr("class", "filename").html("<input disabled value='" + vInfo.filename + "'+title='" + vInfo.filename + "'/>"))
                .append($('<td/>').attr("class", "video-format").html(vInfo.video_format))
                .append($('<td/>').attr("class", "frame-size").html(vInfo.frame_size))
                .append($('<td/>').attr("class", "data-size").html($.formatFileSize(vInfo.data_size)))
                .append($('<td/>').attr("class", "done-time").html("<input disabled value='" + vInfo.complete_time + "' title='" + vInfo.complete_time + "'/>"))
                .append($('<td/>').attr("class", "path").html("<input disabled value='" + vInfo.path + "' title='" + vInfo.path + "'/>"))
                .append($('<td/>').attr('class', 'others')
                    .append($("<a/>").attr("href", "transcode/download/" + vInfo.id).attr('title', '下载').attr('class', 'ui-state-default ui-corner-all need-hover').append($('<span/>').attr('class', 'ui-icon ui-icon-arrowthick-1-s'))
                        .after($("<a/>").attr("href", "javascript:$.showVideoInfo('" + vInfo.id + "','1')").attr('title', '详细信息').attr('class', 'ui-state-default ui-corner-all need-hover').append($('<span/>').attr('class', 'ui-icon ui-icon-info')))))
//                        .after($('<a/>').attr("href", "javascript:void(0)").attr('title', '删除').attr('class', 'cancel ui-state-default ui-corner-all need-hover').append($('<span/>').attr('class', 'ui-icon ui-icon-wrench')))
            doneBlock.append(ytd)
            $.updateIndexNum(doneBlock, "item-index")
        })
    }

    $.showVideoInfo = $.fn.showVideoInfo = function (vId, type) {
        $.getJSON('transcode/video_info', {id: vId, type: type}, function (result) {
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

    $.updateDefaultParams = $.fn.updateDefaultParams = function (ctagBlocks, params) {
//        console.log(ctagBlocks)
        ctagBlocks.each(function () {
            $(this).html($.formatParams(params))
        })
    }

    $.updateTransQueueHtml = $.fn.updateTransQueueHtml = function (htmlBlock, params) {
        if (params.filename)
            $(htmlBlock).find(" .target-filename").val(params.filename).attr('title', params.filename)
        $(htmlBlock).find(" .video-format").html(params.video_format)
        $(htmlBlock).find(" .path").html("<input disabled value='" + params.path + "' title='" + params.path + "'/>")
    }

    $.fileTree = $.fn.fileTree = function (o, proc) {
        // defaults parameters
        if (!o) var o = {};
        if (o.root == undefined) o.root = '/';
        if (o.fileExt == undefined) o.fileExt = null;
        if (o.script == undefined) o.script = 'transcode/file_list';
        if (o.expandSpeed == undefined) o.expandSpeed = 500;
        if (o.collapseSpeed == undefined) o.collapseSpeed = 500;
        if (o.loadMessage == undefined) o.loadMessage = 'Loading...';

        $(this).each(function () {
            function showTree(c, t) {
                var curBlock = $(c)
                var spanBlock = curBlock.find("span:first")
                spanBlock.addClass('wait');
                $.getJSON(o.script, { dir: t, fileExt: o.fileExt}, function (data) {
                    $(".jqueryFileTree.start").remove();
                    curBlock.find('.start').html('');
                    var content = "<ul class=\"jqueryFileTree\" style=\"display: none;\">"
                    if (data['flag']) {
                        for (var v in data['dirs']) {
                            content += "<li class='directory collapsed'>\
                                <input type='checkbox' class='dir-hook' />\
                                <span class='dir'><a href='#' rel='" + data['dirs'][v].path + "'>" + data['dirs'][v].name + "</a></span>\
                             </li>"
                        }
                        for (var v in data['files']) {
                            content += "<li class='file'> \
                                <input type='checkbox' class='file-hook' value='" + data['files'][v].path + "'/>\
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
                            duration: o.expandSpeed,
                            easing: o.expandEasing
                        });
                    bindTree(curBlock);
                });
            }

            function bindTree(t) {
                $(t).find('SPAN A').each(function () {
                    $(this).unbind().bind('click', function () {
                        var curBlock = $(this).parent().parent()
                        if (curBlock.hasClass('directory')) {
                            if (curBlock.hasClass('collapsed')) {
                                curBlock.find('ul').each(function () {
                                    $(this).remove()
                                }); // cleanup
                                showTree(curBlock, $(this).attr('rel'));
                                curBlock.removeClass('collapsed').addClass('expanded');
                                $(this).parent().addClass('exp')
                            } else {
                                // Collapse
                                curBlock.find('ul').slideUp({ duration: o.collapseSpeed, easing: o.collapseEasing });
                                $(this).parent().removeClass('exp')
                                curBlock.removeClass('expanded').addClass('collapsed');
                            }
                        } else {
                            proc($(this).attr('rel'));
                        }
                        return false;
                    });
                });

                $(t).find("input[type='checkbox'][class='dir-hook']").each(function () {
                    var all_hook = $(this)
                    all_hook.click(function () {
                        if ($(this).is(':checked')) {
                            $(this).parent().find("input[type='checkbox'][class='file-hook']").each(function () {
                                if ($(this).attr('disabled') == undefined || $(this).attr('disabled') == false)
                                    $(this).attr("checked", true)
                            })
                        } else {
                            $(this).parent().find("input[type='checkbox'][class='file-hook']").each(function () {
                                if ($(this).attr('disabled') == undefined || $(this).attr('disabled') == false)
                                    $(this).attr("checked", false)
                            })
                        }
                        $(this).attr('checked', $(this).is(':checked'))
                    })
                    $(this).parent().find("input[type='checkbox'][class='file-hook']").each(function () {
                        $(this).click(function () {
                            $(this).attr('checked', $(this).is(':checked'))
                            if (all_hook.is(':checked'))
                                all_hook.attr('checked', false)
                        })
                    })
                })
            }

            // Loading message
            $(this).html('<ul class="jqueryFileTree start"><li><span>' + o.loadMessage + '</span></li></ul>');
            // Get the initial file list
            showTree($(this), o.root);
        })
    }


})(jQuery);


