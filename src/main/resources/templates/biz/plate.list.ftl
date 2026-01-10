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
                            <span class="input-group-addon">${I18n.plate_serviceType}</span>
                            <input type="text" class="form-control" id="serviceType" placeholder="${I18n.system_please_input}${I18n.plate_serviceType}" >
                        </div>
                    </div>
                    <div class="col-xs-3">
                        <div class="input-group">
                            <span class="input-group-addon">${I18n.plate_name}</span>
                            <input type="text" class="form-control" id="name" placeholder="${I18n.system_please_input}${I18n.plate_name}" >
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
                        ｜
                        <button class="btn btn-sm btn-success sumDay" type="button">汇总注单</button>
                        <button class="btn btn-sm btn-success sumAll" type="button">汇总洗码</button>
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
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 class="modal-title" >${I18n.plate_add}</h4>
                    </div>
                    <div class="modal-body">
                        <form class="form-horizontal form" role="form" >

                            <div class="form-group">
                                <label class="col-sm-2 control-label">${I18n.plate_name}<font color="red">*</font></label>
                                <div class="col-sm-4"><input type="text" class="form-control" name="name" maxlength="255" ></div>
                                <label class="col-sm-2 control-label">${I18n.plate_platformAccount}<font color="red">*</font></label>
                                <div class="col-sm-4"><input type="text" class="form-control" name="platformAccount" maxlength="64" ></div>
                            </div>

                            <div class="form-group">
                                <label class="col-sm-2 control-label">${I18n.plate_serviceType}<font color="red">*</font></label>
                                <div class="col-sm-4"><input type="text" class="form-control" name="serviceType" maxlength="64" ></div>
                                <label class="col-sm-2 control-label">${I18n.plate_prefix}<font color="red">*</font></label>
                                <div class="col-sm-4"><input type="text" class="form-control" name="prefix" maxlength="300" ></div>
                            </div>

                            <div class="form-group">
                                <label class="col-sm-2 control-label">${I18n.plate_platformUrl}<font color="red">*</font></label>
                                <div class="col-sm-10"><input type="text" class="form-control" name="platformUrl" maxlength="255" ></div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-2 control-label">${I18n.plate_recordUrl}<font color="red">*</font></label>
                                <div class="col-sm-10"><input type="text" class="form-control" name="recordUrl" maxlength="255" ></div>
                            </div>

                            <div class="form-group">
                                <label class="col-sm-2 control-label">${I18n.plate_priKey}<font color="red">*</font></label>
                                <div class="col-sm-10"><input type="text" class="form-control" name="priKey" maxlength="1000" ></div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-2 control-label">${I18n.plate_pubKey}</label>
                                <div class="col-sm-10"><input type="text" class="form-control" name="pubKey" maxlength="1000" ></div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-2 control-label">${I18n.plate_pub_key}</label>
                                <div class="col-sm-10"><input type="text" class="form-control" name="platePubKey" maxlength="1000" ></div>
                            </div>

                            <div class="form-group">
                                <label class="col-sm-2 control-label">${I18n.white_list}<font color="red">*</font></label>
                                <div class="col-sm-10"><input type="text" class="form-control" name="whiteList" maxlength="500" ></div>
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
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 class="modal-title" >${I18n.plate_edit}</h4>
                    </div>
                    <div class="modal-body">
                        <form class="form-horizontal form" role="form" >

                            <div class="form-group">
                                <label class="col-sm-2 control-label">${I18n.plate_name}<font color="red">*</font></label>
                                <div class="col-sm-4"><input type="text" class="form-control" name="name" maxlength="255" ></div>
                                <label class="col-sm-2 control-label">${I18n.plate_platformAccount}<font color="red">*</font></label>
                                <div class="col-sm-4"><input type="text" class="form-control" name="platformAccount" maxlength="64" ></div>
                            </div>

                            <div class="form-group">
                                <label class="col-sm-2 control-label">${I18n.plate_serviceType}<font color="red">*</font></label>
                                <div class="col-sm-4"><input type="text" class="form-control" name="serviceType" maxlength="64" ></div>
                                <label class="col-sm-2 control-label">${I18n.plate_prefix}<font color="red">*</font></label>
                                <div class="col-sm-4"><input type="text" class="form-control" name="prefix" maxlength="300" ></div>
                            </div>

                            <div class="form-group">
                                <label class="col-sm-2 control-label">${I18n.plate_platformUrl}<font color="red">*</font></label>
                                <div class="col-sm-10"><input type="text" class="form-control" name="platformUrl" maxlength="255" ></div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-2 control-label">${I18n.plate_recordUrl}<font color="red">*</font></label>
                                <div class="col-sm-10"><input type="text" class="form-control" name="recordUrl" maxlength="255" ></div>
                            </div>

                            <div class="form-group">
                                <label class="col-sm-2 control-label">${I18n.plate_priKey}</label>
                                <div class="col-sm-10"><input type="text" class="form-control" name="priKey" placeholder="${I18n.NotChange_notEdit}${I18n.plate_priKey}" maxlength="1000" ></div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-2 control-label">${I18n.plate_pubKey}</label>
                                <div class="col-sm-10"><input type="text" class="form-control" name="pubKey" placeholder="${I18n.NotChange_notEdit}${I18n.plate_pubKey}" maxlength="1000" ></div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-2 control-label">${I18n.plate_pub_key}</label>
                                <div class="col-sm-10"><input type="text" class="form-control" name="platePubKey" placeholder="${I18n.NotChange_notEdit}${I18n.plate_pub_key}" maxlength="1000" ></div>
                            </div>

                            <div class="form-group">
                                <label class="col-sm-2 control-label">${I18n.white_list}<font color="red">*</font></label>
                                <div class="col-sm-10"><input type="text" class="form-control" name="whiteList" maxlength="500" ></div>
                            </div>

                            <hr>
                            <div class="form-group">
                                <div class="col-sm-offset-3 col-sm-6">
                                    <button type="submit" class="btn btn-primary"  >${I18n.system_save}</button>
                                    <button type="button" class="btn btn-default" data-dismiss="modal">${I18n.system_cancel}</button>
                                    <input type="hidden" name="id" >
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

        // sumOrder buttons
        $("#data_operation").on("click", ".sumDay", function() {
            openTab(base_url + "/plate/sumOrder/sportOrderDay", "汇总注单", false);
        });
        $("#data_operation").on("click", ".sumAll", function() {
            openTab(base_url + "/plate/sumOrder/sportOrderAll", "汇总洗码", false);
        });

        // ---------------------- table ----------------------
        $.adminTable.initTable({
            table: '#data_list',
            url: base_url + "/plate/pageList",
            queryParams: function (params) {
                var obj = {};
                obj.serviceType = $('#serviceType').val();
                obj.name = $('#name').val();
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
                    title: 'ID',
                    field: 'id',
                    width: '5',
                    widthUnit: '%'
                },{
                    title: I18n.plate_name,
                    field: 'name',
                    width: '12',
                    widthUnit: '%'
                },{
                    title: I18n.plate_platformAccount,
                    field: 'platformAccount',
                    width: '12',
                    widthUnit: '%'
                },{
                    title: I18n.plate_serviceType,
                    field: 'serviceType',
                    width: '10',
                    widthUnit: '%'
                },{
                    title: I18n.plate_platformUrl,
                    field: 'platformUrl',
                    width: '23',
                    widthUnit: '%',
                    formatter: function(value, row, index) {
                        if (!value) return '';
                        let text = String(value);
                        return '<span title="' + text + '">' + text + '</span>';
                    }
                },{
                    title: I18n.plate_recordUrl,
                    field: 'recordUrl',
                    width: '23',
                    widthUnit: '%',
                    formatter: function(value, row, index) {
                        if (!value) return '';
                        let text = String(value);
                        return '<span title="' + text + '">' + text + '</span>';
                    }
                },{
                    title: I18n.history,
                    field: 'history',
                    width: '8',
                    widthUnit: '%',
                    formatter: function(value, row, index) {
                        return '<a href="javascript:;" class="openHistory" data-type="' + row.serviceType + '" data-acct="' + row.platformAccount + '">' + I18n.history + '</a>';
                    }
                }
            ]
        });

        // open history
        $("#data_list").on("click", ".openHistory", function() {
            let type = $(this).data("type");
            let acct = $(this).data("acct");
            openTab(base_url + "/plate/history/" + encodeURIComponent(type) + "/" + encodeURIComponent(acct), I18n.history, false);
        });

        // ---------------------- add/update/delete ----------------------
        $.adminTable.initDelete({ url: base_url + "/plate/remove" });

        $.adminTable.initAdd({
            url: base_url + "/plate/save",
            rules : {
                name : { required : true, maxlength: 255 },
                platformAccount : { required : true, maxlength: 64 },
                serviceType : { required : true, maxlength: 64 },
                platformUrl : { required : true, maxlength: 255 },
                recordUrl : { required : true, maxlength: 255 },
                priKey : { required : true, maxlength: 1000 },
                prefix : { required : true, maxlength: 300 },
                whiteList : { required : true, maxlength: 500 }
            },
            messages : {
                name : { required : I18n.system_please_input + I18n.plate_name },
                platformAccount : { required : I18n.system_please_input + I18n.plate_platformAccount },
                serviceType : { required : I18n.system_please_input + I18n.plate_serviceType },
                platformUrl : { required : I18n.system_please_input + I18n.plate_platformUrl },
                recordUrl : { required : I18n.system_please_input + I18n.plate_recordUrl },
                priKey : { required : I18n.system_please_input + I18n.plate_priKey },
                prefix : { required : I18n.system_please_input + I18n.plate_prefix },
                whiteList : { required : I18n.system_please_input + I18n.white_list }
            },
            readFormData: function() {
                return $("#addModal .form").serialize();
            }
        });

        $.adminTable.initUpdate({
            url: base_url + "/plate/update",
            rules : {
                id : { required : true },
                name : { required : true, maxlength: 255 },
                platformAccount : { required : true, maxlength: 64 },
                serviceType : { required : true, maxlength: 64 },
                platformUrl : { required : true, maxlength: 255 },
                recordUrl : { required : true, maxlength: 255 },
                prefix : { required : true, maxlength: 300 },
                whiteList : { required : true, maxlength: 500 }
            },
            messages : {
                name : { required : I18n.system_please_input + I18n.plate_name },
                platformAccount : { required : I18n.system_please_input + I18n.plate_platformAccount },
                serviceType : { required : I18n.system_please_input + I18n.plate_serviceType },
                platformUrl : { required : I18n.system_please_input + I18n.plate_platformUrl },
                recordUrl : { required : I18n.system_please_input + I18n.plate_recordUrl },
                prefix : { required : I18n.system_please_input + I18n.plate_prefix },
                whiteList : { required : I18n.system_please_input + I18n.white_list }
            },
            writeFormData: function(row) {
                $("#updateModal .form input[name='id']").val( row.id );
                $("#updateModal .form input[name='name']").val( row.name );
                $("#updateModal .form input[name='platformAccount']").val( row.platformAccount );
                $("#updateModal .form input[name='serviceType']").val( row.serviceType );
                $("#updateModal .form input[name='platformUrl']").val( row.platformUrl );
                $("#updateModal .form input[name='recordUrl']").val( row.recordUrl );
                $("#updateModal .form input[name='prefix']").val( row.prefix );
                $("#updateModal .form input[name='whiteList']").val( row.whiteList );
                $("#updateModal .form input[name='priKey']").val('');
                $("#updateModal .form input[name='pubKey']").val('');
                $("#updateModal .form input[name='platePubKey']").val('');
            },
            readFormData: function() {
                return $("#updateModal .form").serialize();
            }
        });

    });
</script>
<!-- 3-script end -->

</body>
</html>



