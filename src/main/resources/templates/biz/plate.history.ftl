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
                <h3 class="box-title">${I18n.getLossHistory}</h3>
            </div>
            <div class="box-body">

                <div class="row" style="margin-bottom: 10px;">
                    <div class="col-xs-6">
                        <div class="input-group">
                            <span class="input-group-addon">${I18n.startTime} - ${I18n.endTime}</span>
                            <input type="text" class="form-control" id="filterTime" >
                        </div>
                    </div>
                    <div class="col-xs-3" id="currencyDiv" style="display: none">
                        <div class="input-group">
                            <span class="input-group-addon">${I18n.currency}</span>
                            <input type="text" id="currency" class="form-control" >
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-xs-2">
                        <button class="btn btn-block btn-info" id="searchBtn">${I18n.submitOne}</button>
                    </div>
                    <div class="col-xs-2" style="display: none" id="submit2">
                        <button class="btn btn-block btn-info" id="searchBtn2">${I18n.submitTwo}</button>
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

        let serviceType = '${serviceType}';
        let platformAccount = '${platformAccount}';

        if (serviceType && serviceType.startsWith("qx_qx")) {
            $("#currencyDiv").show();
        }
        if (serviceType && serviceType.startsWith("awc_sexy")) {
            $("#submit2").show();
        }

        // init daterangepicker with time+seconds
        $('#filterTime').daterangepicker({
            timePicker: true,
            timePicker24Hour: true,
            timePickerSeconds: true,
            autoUpdateInput: true,
            locale: {
                format: 'YYYY-MM-DD HH:mm:ss',
                applyLabel: I18n.system_ok,
                cancelLabel: I18n.system_cancel
            },
            startDate: moment().subtract(1, 'hours'),
            endDate: moment()
        });

        function checkEmpty(val) {
            return val === undefined || val === null || String(val).trim() === '';
        }

        function buildParam(overrideServiceType) {
            let picker = $('#filterTime').data('daterangepicker');
            if (!picker || !picker.startDate || !picker.endDate) {
                layer.msg(I18n.mustParam + I18n.notEmpty);
                return null;
            }
            let startTime = picker.startDate.format('YYYY-MM-DD HH:mm:ss');
            let endTime = picker.endDate.format('YYYY-MM-DD HH:mm:ss');

            let st = overrideServiceType || serviceType;
            let param = {
                startTime: startTime,
                endTime: endTime,
                serviceType: st,
                platformAccount: platformAccount
            };

            if (st && st.startsWith("qx_qx")) {
                let currency = $('#currency').val();
                if (checkEmpty(currency)) {
                    layer.msg(I18n.currency + I18n.notEmpty);
                    return null;
                }
                param.currency = currency;
            }

            return param;
        }

        function reqHistory(param) {
            $.ajax({
                type: 'POST',
                contentType: 'application/json;charset=utf-8',
                url: base_url + '/plate/history',
                data: JSON.stringify(param),
                dataType: "json",
                success: function (data) {
                    if (data.code === 200) {
                        layer.msg(I18n.getLossHistory + I18n.system_success);
                    } else {
                        layer.open({ icon: '2', content: (data.msg || (I18n.getLossHistory + I18n.system_fail)) });
                    }
                }
            });
        }

        $('#searchBtn').on('click', function () {
            let param = buildParam(null);
            if (!param) return;
            reqHistory(param);
        });

        $('#searchBtn2').on('click', function () {
            let param = buildParam('awc_sexy_tip');
            if (!param) return;
            reqHistory(param);
        });

        $('#resetBtn').on('click', function () {
            $('#currency').val('');
            let picker = $('#filterTime').data('daterangepicker');
            picker.setStartDate(moment().subtract(1, 'hours'));
            picker.setEndDate(moment());
        });

    });
</script>
<!-- 3-script end -->

</body>
</html>



