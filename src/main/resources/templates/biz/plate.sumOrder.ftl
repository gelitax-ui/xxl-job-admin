<!DOCTYPE html>
<html>
<head>
    <#-- import macro -->
    <#import "../common/common.macro.ftl" as netCommon>

    <!-- 1-style start -->
    <@netCommon.commonStyle />
    <link rel="stylesheet" href="${request.contextPath}/static/adminlte/bower_components/bootstrap-daterangepicker/daterangepicker.css">
    <!-- 1-style end -->
</head>
<body class="hold-transition" style="background-color: #ecf0f5;">
<div class="wrapper">
    <section class="content">

        <!-- 2-content start -->
        <div class="box" style="margin-bottom:9px;">
            <div class="box-header">
                <h3 class="box-title">汇总统计</h3>
            </div>
            <div class="box-body">

                <div class="row" style="margin-bottom: 10px;">
                    <div class="col-xs-4">
                        <div class="input-group">
                            <span class="input-group-addon">统计日期</span>
                            <input type="text" class="form-control" id="statDate" >
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-xs-2">
                        <button class="btn btn-block btn-info" id="submitBtn">${I18n.submit}</button>
                    </div>
                    <div class="col-xs-2">
                        <button class="btn btn-block btn-default" id="resetBtn">${I18n.reset}</button>
                    </div>
                </div>

            </div>
        </div>
        <!-- 2-content end -->

    </section>
</div>

<!-- 3-script start -->
<@netCommon.commonScript />
<#-- moment + daterangepicker -->
<script src="${request.contextPath}/static/adminlte/bower_components/moment/moment.min.js"></script>
<script src="${request.contextPath}/static/adminlte/bower_components/bootstrap-daterangepicker/daterangepicker.js"></script>

<script>
    $(function() {

        let type = '${type}';

        // init single date picker
        $('#statDate').daterangepicker({
            singleDatePicker: true,
            showDropdowns: true,
            autoUpdateInput: true,
            locale: {
                format: 'YYYY-MM-DD',
                applyLabel: I18n.system_ok,
                cancelLabel: I18n.system_cancel
            },
            startDate: moment()
        });

        function checkEmpty(val) {
            return val === undefined || val === null || String(val).trim() === '';
        }

        $('#submitBtn').on('click', function () {
            let picker = $('#statDate').data('daterangepicker');
            let dateStr = picker.startDate.format('YYYY-MM-DD');
            if (checkEmpty(dateStr)) {
                layer.msg("统计日期" + I18n.notEmpty);
                return;
            }

            $.ajax({
                type: 'GET',
                url: base_url + '/plate/sumOrder',
                data: { type: type, date: dateStr },
                dataType: "json",
                success: function (data) {
                    if (data.code === 200) {
                        layer.msg(I18n.system_success);
                    } else {
                        layer.open({ icon: '2', content: (data.msg || I18n.system_fail) });
                    }
                }
            });
        });

        $('#resetBtn').on('click', function () {
            let picker = $('#statDate').data('daterangepicker');
            picker.setStartDate(moment());
            picker.setEndDate(moment());
        });

    });
</script>
<!-- 3-script end -->

</body>
</html>



