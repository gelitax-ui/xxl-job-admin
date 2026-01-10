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

                    <div class="col-xs-2">
                        <div class="input-group">
                            <span class="input-group-addon">彩类</span>
                            <input type="text" class="form-control" id="kindId" autocomplete="on">
                        </div>
                    </div>
                    <div class="col-xs-2">
                        <div class="input-group">
                            <span class="input-group-addon">期号</span>
                            <input type="text" class="form-control" id="periodNo" autocomplete="on">
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

        <!-- 2-content end -->

    </section>
</div>

<!-- 3-script start -->
<@netCommon.commonScript />
<script src="${request.contextPath}/static/plugins/bootstrap-table/bootstrap-table.min.js"></script>
<script src="${request.contextPath}/static/plugins/bootstrap-table/locale/<#if I18n.admin_i18n?? && I18n.admin_i18n == 'en'>bootstrap-table-en-US.min.js<#else>bootstrap-table-zh-CN.min.js</#if>"></script>
<#-- admin table -->
<script src="${request.contextPath}/static/biz/common/admin.table.js"></script>
<#-- moment -->
<script src="${request.contextPath}/static/adminlte/bower_components/moment/moment.min.js"></script>

<script>
    $(function() {
        $.adminTable.initTable({
            table: '#data_list',
            url: base_url + "/data/kindId",
            queryParams: function (params) {
                var obj = {};
                obj.kindId = $('#kindId').val();
                obj.periodNo = $('#periodNo').val();
                obj.offset = params.offset;
                obj.pagesize = params.limit;
                return obj;
            },
            columns:[
                {
                    title: '彩类',
                    field: 'kindId',
                    width: '15',
                    widthUnit: '%'
                },{
                    title: '开奖时间',
                    field: 'awardTime',
                    width: '20',
                    widthUnit: '%',
                    formatter: function(value, row, index) {
                        if (!value) return '';
                        return moment(new Date(value)).format("YYYY-MM-DD HH:mm:ss");
                    }
                },{
                    title: '期号',
                    field: 'periodNo',
                    width: '15',
                    widthUnit: '%'
                },{
                    title: '开奖号码',
                    field: 'winNum',
                    width: '20',
                    widthUnit: '%'
                },{
                    title: '记录时间',
                    field: 'recordTime',
                    width: '20',
                    widthUnit: '%',
                    formatter: function(value, row, index) {
                        if (!value) return '';
                        return moment(new Date(value)).format("YYYY-MM-DD HH:mm:ss");
                    }
                }
            ]
        });
    });
</script>
<!-- 3-script end -->

</body>
</html>



