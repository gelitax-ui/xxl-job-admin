<!DOCTYPE html>
<html>
<head>
    <#-- import macro -->
    <#import "../common/common.macro.ftl" as netCommon>

    <!-- 1-style start -->
    <@netCommon.commonStyle />
    <link rel="stylesheet" href="${request.contextPath}/static/plugins/bootstrap-table/bootstrap-table.min.css">
    <!-- 1-style end -->

</head>
<body class="hold-transition" style="background-color: #ecf0f5;">
<div class="wrapper">
    <section class="content">

        <!-- 2-content start -->

        <#-- 查询区域 -->
        <div class="box" style="margin-bottom:9px;">
            <div class="box-body">
                <div class="row" id="data_filter" >

                    <div class="col-xs-3">
                        <div class="input-group">
                            <span class="input-group-addon">${I18n.conf_sys_key}</span>
                            <input type="text" class="form-control" id="sysKey" placeholder="${I18n.system_please_input}${I18n.conf_sys_key}" >
                        </div>
                    </div>

                    <div class="col-xs-1">
                        <button class="btn btn-block btn-primary searchBtn" >${I18n.system_search}</button>
                    </div>
                    <div class="col-xs-1">
                        <button class="btn btn-block btn-default resetBtn" >${I18n.system_reset}</button>
                    </div>
                </div>
            </div>
        </div>

        <#-- 数据表格区域 -->
        <div class="row">
            <div class="col-xs-12">
                <div class="box">
                    <div class="box-header pull-left" id="data_operation" >
                        <button class="btn btn-sm btn-info add" type="button"><i class="fa fa-plus" ></i>${I18n.system_opt_add}</button>
                        <button class="btn btn-sm btn-warning selectOnlyOne update disabled" type="button"><i class="fa fa-edit"></i>${I18n.system_opt_edit}</button>
                        <button class="btn btn-sm btn-danger selectAny delete disabled" type="button"><i class="fa fa-remove "></i>${I18n.system_opt_del}</button>
                    </div>
                    <div class="box-body" >
                        <table id="data_list" class="table table-bordered table-striped" width="100%" >
                            <thead></thead>
                            <tbody></tbody>
                            <tfoot></tfoot>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- 新增.模态框 -->
        <div class="modal fade" id="addModal" tabindex="-1" role="dialog"  aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 class="modal-title" >${I18n.conf_add}</h4>
                    </div>
                    <div class="modal-body">
                        <form class="form-horizontal form" role="form" >
                            <div class="form-group">
                                <label class="col-sm-3 control-label">${I18n.conf_sys_key}<font color="red">*</font></label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control" name="sysKey" placeholder="${I18n.system_please_input}${I18n.conf_sys_key}" maxlength="64" >
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">${I18n.conf_sys_value}<font color="red">*</font></label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control" name="sysValue" placeholder="${I18n.system_please_input}${I18n.conf_sys_value}" maxlength="2000" >
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">${I18n.conf_common_key}</label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control" name="commonKey" placeholder="${I18n.system_please_input}${I18n.conf_common_key}" maxlength="64" >
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">${I18n.conf_sys_desc}</label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control" name="description" placeholder="${I18n.system_please_input}${I18n.conf_sys_desc}" maxlength="255" >
                                </div>
                            </div>
                            <hr>
                            <div class="form-group">
                                <div class="col-sm-offset-3 col-sm-6">
                                    <button type="submit" class="btn btn-primary"  >${I18n.system_save}</button>
                                    <button type="button" class="btn btn-default" data-dismiss="modal">${I18n.system_cancel}</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- 更新.模态框 -->
        <div class="modal fade" id="updateModal" tabindex="-1" role="dialog"  aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 class="modal-title" >${I18n.conf_edit}</h4>
                    </div>
                    <div class="modal-body">
                        <form class="form-horizontal form" role="form" >
                            <div class="form-group">
                                <label class="col-sm-3 control-label">${I18n.conf_sys_key}<font color="red">*</font></label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control" name="sysKey" readonly="readonly" maxlength="64" >
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">${I18n.conf_sys_value}<font color="red">*</font></label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control" name="sysValue" placeholder="${I18n.system_please_input}${I18n.conf_sys_value}" maxlength="2000" >
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">${I18n.conf_common_key}</label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control" name="commonKey" placeholder="${I18n.system_please_input}${I18n.conf_common_key}" maxlength="64" >
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">${I18n.conf_sys_desc}</label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control" name="description" placeholder="${I18n.system_please_input}${I18n.conf_sys_desc}" maxlength="255" >
                                </div>
                            </div>
                            <hr>
                            <div class="form-group">
                                <div class="col-sm-offset-3 col-sm-6">
                                    <button type="submit" class="btn btn-primary"  >${I18n.system_save}</button>
                                    <button type="button" class="btn btn-default" data-dismiss="modal">${I18n.system_cancel}</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- 2-content end -->

    </section>
</div>

<!-- 3-script start -->
<@netCommon.commonScript />
<script src="${request.contextPath}/static/plugins/bootstrap-table/bootstrap-table.min.js"></script>
<script src="${request.contextPath}/static/plugins/bootstrap-table/locale/<#if I18n.admin_i18n?? && I18n.admin_i18n == 'en'>bootstrap-table-en-US.min.js<#else>bootstrap-table-zh-CN.min.js</#if>"></script>
<#-- admin table -->
<script src="${request.contextPath}/static/biz/common/admin.table.js"></script>
<#-- admin util -->
<script src="${request.contextPath}/static/biz/common/admin.util.js"></script>

<script>
    $(function() {

        // ---------------------- table ----------------------
        $.adminTable.initTable({
            table: '#data_list',
            url: base_url + "/conf/pageList",
            queryParams: function (params) {
                var obj = {};
                obj.sysKey = $('#sysKey').val();
                obj.offset = params.offset;
                obj.pagesize = params.limit;
                return obj;
            },
            columns:[
                {
                    checkbox: true,
                    field: 'state',
                    width: '3',
                    widthUnit: '%',
                    align: 'center',
                    valign: 'middle'
                },{
                    title: I18n.conf_sys_key,
                    field: 'sysKey',
                    width: '15',
                    widthUnit: '%'
                },{
                    title: I18n.conf_sys_value,
                    field: 'sysValue',
                    width: '35',
                    widthUnit: '%',
                    formatter: function(value, row, index) {
                        if (!value) {
                            return '';
                        }
                        let text = String(value);
                        if (text.length > 40) {
                            return '<span title="' + text + '">' + text.substr(0, 40) + '...</span>';
                        }
                        return text;
                    }
                },{
                    title: I18n.conf_common_key,
                    field: 'commonKey',
                    width: '10',
                    widthUnit: '%'
                },{
                    title: I18n.conf_sys_desc,
                    field: 'description',
                    width: '20',
                    widthUnit: '%'
                },{
                    title: I18n.conf_sys_host,
                    field: 'serverHealth',
                    width: '10',
                    widthUnit: '%',
                    formatter: function(value, row, index) {
                        if (row.commonKey !== 'host') {
                            return '';
                        }
                        let health = (row.serverHealth === '1' || row.serverHealth === 1) ? '正常' : '异常';
                        let cls = (health === '正常') ? 'label label-success' : 'label label-danger';
                        return '<span class="' + cls + '" style="margin-right:6px;">' + health + '</span>'
                            + '<button class="btn btn-xs btn-info checkNet" data-syskey="' + row.sysKey + '">' + I18n.conf_sys_host + '</button>';
                    }
                }
            ]
        });

        // ---------------------- add/update/delete ----------------------
        $.adminTable.initDelete({ url: base_url + "/conf/remove" });

        $.adminTable.initAdd({
            url: base_url + "/conf/save",
            rules : {
                sysKey : { required : true, maxlength: 64 },
                sysValue : { required : true, maxlength: 2000 }
            },
            messages : {
                sysKey : { required : I18n.system_please_input + I18n.conf_sys_key },
                sysValue : { required : I18n.system_please_input + I18n.conf_sys_value }
            },
            readFormData: function() {
                return $("#addModal .form").serialize();
            }
        });

        $.adminTable.initUpdate({
            url: base_url + "/conf/update",
            rules : {
                sysKey : { required : true, maxlength: 64 },
                sysValue : { required : true, maxlength: 2000 }
            },
            messages : {
                sysKey : { required : I18n.system_please_input + I18n.conf_sys_key },
                sysValue : { required : I18n.system_please_input + I18n.conf_sys_value }
            },
            writeFormData: function(row) {
                $("#updateModal .form input[name='sysKey']").val( row.sysKey );
                $("#updateModal .form input[name='sysValue']").val( row.sysValue );
                $("#updateModal .form input[name='commonKey']").val( row.commonKey );
                $("#updateModal .form input[name='description']").val( row.description );
            },
            readFormData: function() {
                return $("#updateModal .form").serialize();
            }
        });

        // ---------------------- checkNet ----------------------
        $("#data_list").on('click', '.checkNet', function() {
            let sysKey = $(this).data("syskey");
            $.ajax({
                type : 'POST',
                url : base_url + '/conf/checkNet',
                data : { "sysKey": sysKey },
                dataType : "json",
                success : function(data){
                    if (data.code === 200) {
                        layer.msg(I18n.conf_sys_host + I18n.system_success);
                        $('#data_filter .searchBtn').click();
                    } else {
                        layer.open({ icon: '2', content: (data.msg || (I18n.conf_sys_host + I18n.system_fail)) });
                        $('#data_filter .searchBtn').click();
                    }
                }
            });
        });

    });
</script>
<!-- 3-script end -->

</body>
</html>



