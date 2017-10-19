<%-- 
    Document   : index
    Created on : 04/09/2017, 4:42:48 PM
    Author     : jyf
--%>
<%--<%@page import="java.sql.*" %> --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>ENSAT Data Quality Report</title>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
        
        <script src="https://code.highcharts.com/highcharts.js"></script>
        <script src="https://code.highcharts.com/modules/exporting.js"></script>

        <script src="https://code.highcharts.com/highcharts-3d.js"></script>

        <script type="text/javascript">
            function showHide() {
            $("#showdiv").toggle();
            }
            function showHide1() {
            $("#showdiv1").toggle();
            }
            function showHide2() {
            $("#showdiv2").toggle();
            }
        </script>
        <%

            String connectionURL = "jdbc:mysql://localhost:3306/ENSAT";
            String driverName = "com.mysql.jdbc.Driver";
            java.sql.Connection connection = null;
            String username = "root";
            String password = "0906";
            String[] ensat_dbs = {"ACC", "NAPACA", "Pheo", "APA"};
            int[] output = new int[4];
            int output1 = 0;
            int recordCountNAPACA = 0;
            int recordCountACC = 0;
            int[] pathologyACC = new int[3];
            int[] pathologyNAPACA = new int[3];
            int[] imagingACC = new int[2];
            int[] imagingNAPACA = new int[2];

            String[] sqlPathology = {";", " AND ki67<>'';", "AND weiss_score<>'';"};

            String[] sqlSurgery = {"AND pathology_diagnosis <> 'Adrenocortical Adenoma'",
                " AND pathology_diagnosis = 'Adrenocortical Adenoma' AND ki67 >= '0' AND weiss_score != ''"};

            String[] sqlImagingACC = {";", "AND imaging<>'';"};
            String[] sqlImagingNAPACA = {";", "AND imaging_of_tumor<>'';"};

            try {
                Class.forName(driverName).newInstance();
                connection = java.sql.DriverManager.getConnection(connectionURL, username, password);

                //count totall number of records in different database
                for (int i = 0; i < ensat_dbs.length; i++) {

                    String sql = "SELECT COUNT(ensat_database) FROM ENSAT.Identification WHERE ensat_database='" + ensat_dbs[i] + "';";
                    java.sql.PreparedStatement ps = connection.prepareStatement(sql);
                    java.sql.ResultSet rs = ps.executeQuery();

                    while (rs.next()) {
                        output[i] = Integer.parseInt(rs.getString(1));

                    }
                    ps.close();

                }

                //count the number of records associated with EURINE-ACT Study
                String sql1 = "SELECT COUNT(*) FROM ENSAT.Identification INNER JOIN  ENSAT.Associated_Studies"
                        + " ON ENSAT.Identification.ensat_id = ENSAT.Associated_Studies.ensat_id"
                        + " AND ENSAT.Identification.center_id = ENSAT.Associated_Studies.center_id"
                        + " WHERE ENSAT.Associated_Studies.study_label = 'EURINE-ACT';";
                java.sql.PreparedStatement ps = connection.prepareStatement(sql1);
                java.sql.ResultSet rs = ps.executeQuery();

                while (rs.next()) {
                    output1 = Integer.parseInt(rs.getString(1));
                }

                ps.close();

                //count the eligibile NAPACA records without surgery
                String sql2 = "SELECT COUNT(*) FROM ENSAT.NAPACA_Biomaterial"
                        + " INNER JOIN ENSAT.Associated_Studies"
                        + " ON ENSAT.NAPACA_Biomaterial.ensat_id = ENSAT.Associated_Studies.ensat_id"
                        + " AND ENSAT.NAPACA_Biomaterial.center_id = ENSAT.Associated_Studies.center_id"
                        + " INNER JOIN ENSAT.NAPACA_Imaging"
                        + " ON ENSAT.Associated_Studies.ensat_id = ENSAT.NAPACA_Imaging.ensat_id"
                        + " AND ENSAT.Associated_Studies.center_id = ENSAT.NAPACA_Imaging.center_id"
                        + " WHERE ENSAT.Associated_Studies.study_label = 'EURINE-ACT'"
                        + " AND 24h_urine > '10' AND spot_urine > '10' AND serum > '1'  AND heparin_plasma >'1.5'"
                        + " AND napaca_biomaterial_id = '1' AND napaca_imaging_id = '1'"
                        + " AND NOT EXISTS("
                        + " SELECT * FROM ENSAT.NAPACA_Surgery"
                        + " WHERE ENSAT.NAPACA_Biomaterial.ensat_id = ENSAT.NAPACA_Surgery.ensat_id"
                        + " AND ENSAT.NAPACA_Biomaterial.center_id = ENSAT.NAPACA_Surgery.center_id);";

                java.sql.PreparedStatement ps2 = connection.prepareStatement(sql2);
                java.sql.ResultSet rs2 = ps2.executeQuery();

                while (rs2.next()) {
                    recordCountNAPACA = Integer.parseInt(rs2.getString(1));
                }
                ps.close();

                //count eligible records in NAPACA with surgery
                for (int i = 0; i < sqlSurgery.length; i++) {
                    String sql3 = "SELECT COUNT(*) FROM ENSAT.NAPACA_Biomaterial"
                            + " INNER JOIN ENSAT.Associated_Studies"
                            + " ON ENSAT.NAPACA_Biomaterial.ensat_id = ENSAT.Associated_Studies.ensat_id"
                            + " AND ENSAT.NAPACA_Biomaterial.center_id = ENSAT.Associated_Studies.center_id"
                            + " INNER JOIN ENSAT.NAPACA_Imaging"
                            + " ON ENSAT.Associated_Studies.ensat_id = ENSAT.NAPACA_Imaging.ensat_id"
                            + " AND ENSAT.Associated_Studies.center_id = ENSAT.NAPACA_Imaging.center_id"
                            + " INNER JOIN ENSAT.NAPACA_Surgery"
                            + " ON ENSAT.NAPACA_Biomaterial.ensat_id = ENSAT.NAPACA_Surgery.ensat_id"
                            + " AND ENSAT.NAPACA_Biomaterial.center_id = ENSAT.NAPACA_Surgery.center_id"
                            + " INNER JOIN ENSAT.NAPACA_Pathology"
                            + " ON ENSAT.NAPACA_Biomaterial.ensat_id = ENSAT.NAPACA_Pathology.ensat_id"
                            + " AND ENSAT.NAPACA_Biomaterial.center_id = ENSAT.NAPACA_Pathology.center_id"
                            + " WHERE ENSAT.Associated_Studies.study_label = 'EURINE-ACT'"
                            + " AND 24h_urine > '10'AND spot_urine > '10' AND serum > '1'"
                            + " AND heparin_plasma >'1.5' AND napaca_biomaterial_id = '1'"
                            + " AND napaca_imaging_id = '1' " + sqlSurgery[i];

                    java.sql.PreparedStatement ps3 = connection.prepareStatement(sql3);
                    java.sql.ResultSet rs3 = ps3.executeQuery();

                    while (rs3.next()) {
                        recordCountNAPACA += Integer.parseInt(rs3.getString(1));
                    }
                    ps3.close();
                }

                //count eligible records in ACC
                String sql4 = "SELECT COUNT(*) FROM ENSAT.ACC_Biomaterial"
                        + " INNER JOIN ENSAT.Associated_Studies"
                        + " ON ENSAT.ACC_Biomaterial.ensat_id = ENSAT.Associated_Studies.ensat_id"
                        + " AND ENSAT.ACC_Biomaterial.center_id = ENSAT.Associated_Studies.center_id"
                        + " WHERE study_label = 'EURINE-ACT'"
                        + " AND 24h_urine > '10' AND spot_urine > '10' AND serum > '1'"
                        + " AND heparin_plasma >'1.5' AND acc_biomaterial_id = '1' AND EXISTS("
                        + " SELECT * FROM ENSAT.ACC_Surgery"
                        + " WHERE ENSAT.ACC_Biomaterial.ensat_id = ENSAT.ACC_Surgery.ensat_id"
                        + " AND ENSAT.ACC_Biomaterial.center_id = ENSAT.ACC_Surgery.center_id);";
                java.sql.PreparedStatement ps4 = connection.prepareStatement(sql4);
                java.sql.ResultSet rs4 = ps4.executeQuery();

                while (rs4.next()) {
                    recordCountACC = Integer.parseInt(rs4.getString(1));
                }
                ps4.close();

                /* count the specific data
                 */
                //count total number of ACC_pathology records, number of completed ki67 and weiss score records in ACC
                for (int i = 0; i < sqlPathology.length; i++) {
                    String sql5 = "SELECT COUNT(*) FROM ENSAT.ACC_Pathology"
                            + " INNER JOIN Associated_Studies"
                            + " ON ENSAT.ACC_Pathology.ensat_id = ENSAT.Associated_Studies.ensat_id"
                            + " AND ENSAT.ACC_Pathology.center_id = ENSAT.Associated_Studies.center_id"
                            + " WHERE study_label = 'EURINE-ACT'" + sqlPathology[i];

                    java.sql.PreparedStatement ps5 = connection.prepareStatement(sql5);
                    java.sql.ResultSet rs5 = ps5.executeQuery();

                    while (rs5.next()) {
                        pathologyACC[i] = Integer.parseInt(rs5.getString(1));
                    }
                    ps5.close();
                }

                //count total number of NAPACA_pathology records, number of completed ki67 and weiss score records in NAPACA
                for (int i = 0; i < sqlPathology.length; i++) {
                    String sql6 = "SELECT COUNT(*) FROM ENSAT.NAPACA_Pathology"
                            + " INNER JOIN Associated_Studies"
                            + " ON ENSAT.NAPACA_Pathology.ensat_id = ENSAT.Associated_Studies.ensat_id"
                            + " AND ENSAT.NAPACA_Pathology.center_id = ENSAT.Associated_Studies.center_id"
                            + " WHERE study_label = 'EURINE-ACT'" + sqlPathology[i];

                    java.sql.PreparedStatement ps6 = connection.prepareStatement(sql6);
                    java.sql.ResultSet rs6 = ps6.executeQuery();

                    while (rs6.next()) {
                        pathologyNAPACA[i] = Integer.parseInt(rs6.getString(1));
                    }
                    ps6.close();
                }

                //count number of ACC_imaging records
                for (int i = 0; i < sqlImagingACC.length; i++) {
                    String sql7 = "SELECT COUNT(DISTINCT (assoc_study_id)) FROM ENSAT.Associated_Studies"
                            + " INNER JOIN ENSAT.ACC_Imaging"
                            + " ON  ENSAT.Associated_Studies.ensat_id = ENSAT.ACC_Imaging.ensat_id"
                            + " AND  ENSAT.Associated_Studies.center_id = ENSAT.ACC_Imaging.center_id"
                            + " WHERE study_label = 'EURINE-ACT'"
                            + " AND ENSAT.ACC_Imaging.center_id<>''"
                            + " ORDER BY ENSAT.ACC_Imaging.ensat_id " + sqlImagingACC[i];
                    java.sql.PreparedStatement ps7 = connection.prepareStatement(sql7);
                    java.sql.ResultSet rs7 = ps7.executeQuery();

                    while (rs7.next()) {
                        imagingACC[i] = Integer.parseInt(rs7.getString(1));
                    }
                    ps7.close();
                }
                //count number of NAPACA_imaging records
                for (int i = 0; i < sqlImagingNAPACA.length; i++) {
                    String sql8 = "SELECT COUNT(DISTINCT (assoc_study_id)) FROM ENSAT.Associated_Studies"
                            + " INNER JOIN ENSAT.NAPACA_Imaging"
                            + " ON  ENSAT.Associated_Studies.ensat_id = ENSAT.NAPACA_Imaging.ensat_id"
                            + " AND  ENSAT.Associated_Studies.center_id = ENSAT.NAPACA_Imaging.center_id"
                            + " WHERE study_label = 'EURINE-ACT'"
                            + " AND ENSAT.NAPACA_Imaging.center_id<>''" + sqlImagingNAPACA[i];
                    java.sql.PreparedStatement ps8 = connection.prepareStatement(sql8);
                    java.sql.ResultSet rs8 = ps8.executeQuery();

                    while (rs8.next()) {
                        imagingNAPACA[i] = Integer.parseInt(rs8.getString(1));
                    }
                    ps8.close();
                }
            } catch (Exception e) {
                System.out.println("Database connection error: " + e.getMessage());
            }
        %>
    </head>
    <body>
        <div class="the whole page" style="margin:0 auto">
            <div class="header" style="background-image:url('head');background-repeat:no-repeat;
                 background-position:left top;height:126px;width:919px;margin:0 auto"></div>
                 <div style="color:darkslateblue;width:919px;margin:0 auto;text-align: center;padding: 20px 0 20px 0">
                     <b><h1 style="font-size: 45px">The Data Quality Report</h1></b></div>
                 <div>
                     <div style='margin:0 auto;width:919px'>
                         <h1 style="color:gray;align-content: center;font-size: 24px" >❀ Overall Statistic</h1></div>

                <div id="container" style="width:700px;height:400px;margin:0 auto"> 

                    <script>
                        Highcharts.chart('container', {
                        chart: {
                        type: 'column'
                        },
                                title: {
                                text: 'Number of records stored in database',
                                },
                                subtitle: {
                                text: 'overview'
                                },
                                xAxis: {
                                categories: [
                        <%for (int i = 0; i < ensat_dbs.length; i++) {%>
                                '<%=ensat_dbs[i]%>'
                        <%if (i != ensat_dbs.length - 1) {%>
                                ,<%}%>
                        <%}%>
                                ],
                                        crosshair: true
                                },
                                yAxis: {
                                min: 0,
                                        title: {
                                        text: 'number'
                                        }
                                },
                                tooltip: {
                                headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                                        pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                                        '<td style="padding:0"><b>{point.y:f} </b></td></tr>',
                                        footerFormat: '</table>',
                                        shared: true,
                                        useHTML: true
                                },
                                plotOptions: {
                                column: {
                                pointPadding: 0.3,
                                        borderWidth: 0
                                }
                                },
                                series:[
                        <%for (int i = 0; i < ensat_dbs.length; i++) {%>
                                {
                                name: '<%=ensat_dbs[i]%>',
                                        data: [<%=output[i]%>]
                                }
                        <%if (i != ensat_dbs.length - 1) {%>
                                ,<%}%>
                        <%}%>
                                ]
                        });
                    </script>
                </div>
                <h3 style="color:background;margin:0 auto;width:919px">→ The overall number of records in ENSAT database is <mark style="color: pink"><%=output[0] + output[1] + output[2] + output[3]%></mark>.</h3>
            </div>
            <div
                <div style='margin:0 auto;width:919px'><h1 style="color:gray; font-size: 24px;">❀ Data Associated with EURINE-ACT Study</h1></div>

                <div>
                    <div style='margin:0 auto;width:919px'>
                        <a style="font-size: 24px;color: gray;" href="javascript:;" onclick="showHide()">☆ Overall statistic</a></div>
                    <div id = "showdiv" style="display:none;">
                        <p></p>
                        <div id="container1" style="width:500px;height:350px;margin: 0 auto">
                            <script>
                                Highcharts.chart('container1', {
                                chart: {
                                type: 'area'
                                },
                                        title: {
                                        text: 'Number Of Records Assotiated With EURINE-ACT Study'
                                        },
                                        xAxis: {
                                        categories: ['2014', '2017'],
                                                tickmarkPlacement: 'on',
                                                title: {
                                                enabled: false
                                                }
                                        },
                                        yAxis: {
                                        title: {
                                        text: 'Number of Records'
                                        },
                                                labels: {
                                                formatter: function () {
                                                return this.value / 1000;
                                                }
                                                }
                                        },
                                        tooltip: {
                                        split: true,
                                        },
                                        plotOptions: {
                                        area: {
                                        stacking: 'normal',
                                                lineColor: '#666666',
                                                lineWidth: 1,
                                                marker: {
                                                lineWidth: 1,
                                                        lineColor: '#666666'
                                                }
                                        }
                                        },
                                        series: [{
                                        name: 'ENSAT Database',
                                                data: [6192, <%=output[0] + output[1] + output[2] + output[3]%>]
                                        }, {
                                        name: 'EURINE-ACT related',
                                                data: [546, <%=output1%>]
                                        }]
                                });
                            </script>
                        </div>
                    </div>
                </div>
                <div>
                    <div style='margin:0 auto;width:919px'>
                    <a style="font-size: 24px;color: gray;margin:0 auto;width:919px" href="javascript:;" onclick="showHide1()">☆ Eligibility statistic</a>
                    </div>
                    <div id = "showdiv1" style="display:none;">
                        <div style='margin:0 auto;width:919px'>
                        <h3 style="color: gray">·Eligible Records for EURINE-ACT Study</h3>
                        </div>
                        <div id="container2" style="width:500px;height:400px;margin: 0 auto">
                            <script>
                                Highcharts.chart('container2', {
                                chart: {
                                type: 'column'
                                },
                                        title: {
                                        text: 'Number Of Eligible Records in ACC and NAPACA',
                                        },
                                        xAxis: {
                                        categories: [
                                                'ACC',
                                                'NAPACA'
                                        ],
                                                crosshair: true
                                        },
                                        yAxis: {
                                        min: 0,
                                                title: {
                                                text: 'number'
                                                }
                                        },
                                        tooltip: {
                                        headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                                                pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                                                '<td style="padding:0"><b>{point.y:f} </b></td></tr>',
                                                footerFormat: '</table>',
                                                shared: true,
                                                useHTML: true
                                        },
                                        plotOptions: {
                                        column: {
                                        pointPadding: 0.3,
                                                borderWidth: 0
                                        }
                                        },
                                        series: [{
                                        name: 'ACC',
                                                data: [<%=recordCountACC%>]
                                        }, {
                                        name: 'NAPACA',
                                                data: [<%=recordCountNAPACA%>]
                                        }]
                                });
                            </script>
                        </div>
                              <div style='margin:0 auto;width:919px'>          
                        <h3 style="color: gray">·Eligiblility Rate</h3>
                              </div>
                        <div>
                            <div id="container3" style=" width: 500px; height: 500px;  margin: 0 auto">
                                <script>
                                    Highcharts.chart('container3', {
                                    chart: {
                                    type: 'pie',
                                            options3d: {
                                            enabled: true,
                                                    alpha: 45,
                                                    beta: 0
                                            }
                                    },
                                            title: {
                                            text: 'Data Eligibility Rate for EURINE-ACT Study'
                                            },
                                            tooltip: {
                                            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
                                            },
                                            plotOptions: {
                                            pie: {
                                            allowPointSelect: true,
                                                    cursor: 'pointer',
                                                    depth: 35,
                                                    dataLabels: {
                                                    enabled: true,
                                                            format: '{point.name}'
                                                    }
                                            }
                                            },
                                            series: [{
                                            type: 'pie',
                                                    name: 'Number of records in ENSAT database',
                                                    data: [
                                                    ['Not eligible', <%=output1 - recordCountACC - recordCountNAPACA%>],
                                                    {
                                                    name: 'ACC_eligible',
                                                            y: <%=recordCountACC%>,
                                                            sliced: true,
                                                            selected: true
                                                    },
                                                    ['NAPACA_eligible', <%=recordCountNAPACA%>]
                                                    ]
                                            }]
                                    });
                                </script>
                            </div>
                        </div>
                    </div>
                </div>
                <div>
                    <div style='margin:0 auto;width:919px'>
                    <a style="font-size: 24px;color: gray;" href="javascript:;" onclick="showHide2()">☆ Data completeness of specific items</a>
                    </div>
                    <div id = "showdiv2" style="display:none;">
                        <div style='margin:0 auto;width:919px'>
                            <h3 style="color: gray">☆ Select the very important items for treatment decision and research:</h3></div>
                        <div id="container4" style="width:700px;height:400px;margin:0 auto">
                            <script>
                                Highcharts.chart('container4', {
                                chart: {
                                type: 'bar'
                                },
                                        title: {
                                        text: 'Data Completeness of the important items'
                                        },
                                        xAxis: {
                                        categories: ['ki67', 'weiss score', 'imaging']
                                        },
                                        yAxis: {
                                        min: 0,
                                                title: {
                                                text: 'Data Completeness'
                                                }
                                        },
                                        legend: {
                                        reversed: true
                                        },
                                        tooltip: {
                                        pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.y}</b> ({point.percentage:.0f}%)<br/>',
                                                shared: true
                                        },
                                        plotOptions: {
                                        series: {
                                        stacking: 'percent'
                                        }
                                        },
                                        series: [ {
                                        name: 'Missing information',
                                                data: [<%=pathologyACC[0] + pathologyNAPACA[0] - pathologyACC[1] - pathologyNAPACA[1]%>,<%=pathologyACC[0] + pathologyNAPACA[0] - pathologyACC[2] - pathologyNAPACA[2]%>,
                                <%=imagingACC[0] + imagingNAPACA[0] - imagingACC[1] - imagingNAPACA[1]%>]
                                        }, {
                                        name: 'Completed data',
                                                data: [<%=pathologyACC[1] + pathologyNAPACA[1]%>, <%=pathologyACC[2] + pathologyNAPACA[2]%>,
                                <%=imagingACC[1] + imagingNAPACA[1]%> ]
                                        }]
                                });
                            </script>
                        </div>
                    </div>
                </div>

            </div>
            <div class="footer"style="background-image:url('footer');background-repeat:no-repeat;
                 background-position:left bottom;height:39px;width:919px;margin:0 auto"></div>
        </div>
    </body>
</html>
