/**
 * Created with JetBrains RubyMine.
 * User: valder
 * Date: 12-11-22
 * Time: 上午2:20
 * To change this template use File | Settings | File Templates.
 */

(function ($) {


    $.deleteFiles = $.fn.deleteFiles = function (fileIds, token) {
        $.post('upload/delete', {data:fileIds, authenticity_token:token}, function (result) {
            if (result['flag'] == true) {
                for (var id in fileIds) {
                    if(result[id]['flag']==true)
                        $('#upload_done_list .video-' + id).html("")
                    else
                        $('#upload_done_list .video-' + id).find(".filename").css('color', 'red').append(" -删除异常")
                }
            }
        }, 'json')
    }

    $.updateDoneList = $.fn.updateDoneList = function (tableBlock, fileListBlock, token) {
        $.getJSON("upload/list", {}, function (result) {
            if (result['flag'] == true) {
                var data = result['data']
                if (data.length == 0)
                    fileListBlock.html("没有上传的视频文件")
                else {
                    fileListBlock.html("")
                    var i = 1
                    for (var a in data) {
                        var ytd = $("<tr/>").attr('class', 'video-' + data[a]['id'])
                        ytd.append($('<td/>').attr("class", "item-index").append($('<input>').val(data[a]['id']).attr("type", "checkbox").attr("class", "checkbox-item-hook")).append($('<span/>').attr("class", "index-hook").html(0)))
                            .append($('<td/>').attr("class", "filename").html('<input disabled value="' + data[a]['filename'] + '"/>'))
                            .append($('<td/>').attr("class", "info").html('<input disabled value="' + $.formatVideoInfo(data[a]) + '"/>'))
                            .append($('<td/>').attr("class", "time").html('<input disabled value="' + data[a]['created_at'] + '"/>'))
                            .append($('<td/>').attr('class', 'others')
                            .append($("<a/>").attr("href", "javascript:$.showVideoInfoFromUpload('" + data[a]['id'] + "')").attr('title', '详细信息').attr('class', 'ui-state-default ui-corner-all need-hover').append($('<span/>').attr('class', 'ui-icon ui-icon-info')))
                            .append($('<a/>').attr("href", "javascript:$.deleteFiles([" + data[a]['id'] + "],'" + token + "')").attr('title', '删除记录').attr('class', 'cancel ui-state-default ui-corner-all need-hover').append($('<span/>').attr('class', 'ui-icon ui-icon-trash')))
                        )
                        fileListBlock.append(ytd)
                    }
                    $.updateIndexNum(fileListBlock, "item-index")
                    $.bindCheckboxAll(tableBlock)
                    $.bindHover()
                }
            }
        })
    }

})(jQuery);

