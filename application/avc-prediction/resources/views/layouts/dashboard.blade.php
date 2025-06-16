<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>AdminLTE 3 | ChartJS</title>

    <!-- Google Font: Source Sans Pro -->
    <link rel="stylesheet"
        href="{{ asset('https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback') }}" />
    <!-- Font Awesome -->
    <link rel="stylesheet" href="{{ asset('plugins/fontawesome-free/css/all.min.css') }}" />
    <!-- Theme style -->
    <link rel="stylesheet" href="{{ asset('dist/css/adminlte.min.css') }}" />
</head>

<body class="hold-transition sidebar-mini">
    <div class="wrapper">
        <!-- Navbar -->
        <nav class="main-header navbar navbar-expand navbar-white navbar-light">
            <!-- Left navbar links -->
            <ul class="navbar-nav">
                <li class="nav-item">
                    <a class="nav-link" data-widget="pushmenu" href="#" role="button"><i
                            class="fas fa-bars"></i></a>
                </li>
                <li class="nav-item d-none d-sm-inline-block">
                    <a href="../../index3.html" class="nav-link">Home</a>
                </li>
                <li class="nav-item d-none d-sm-inline-block">
                    <a href="#" class="nav-link">Contact</a>
                </li>
            </ul>

            <!-- Right navbar links -->
            <ul class="navbar-nav ml-auto">


                <li class="nav-item">
                    <a class="nav-link" data-widget="fullscreen" href="#" role="button">
                        <i class="fas fa-expand-arrows-alt"></i>
                    </a>
                </li>

            </ul>
        </nav>
        <!-- /.navbar -->
        <!-- Main Sidebar Container -->
        <aside class="main-sidebar sidebar-dark-primary elevation-4">
            <!-- Logo -->
            <a href="{{ url('/admin') }}" class="brand-link">
                <img src="{{ asset('dist/img/AdminLTELogo.png') }}" alt="Logo"
                    class="brand-image img-circle elevation-3" style="opacity: .8">
                <span class="brand-text font-weight-light">AVC-Predict</span>
            </a>

            <!-- Sidebar -->
            <div class="sidebar">
                <!-- User panel -->
                <div class="user-panel mt-3 pb-3 mb-3 d-flex">
                    <div class="image">
                        <img src="{{ asset('dist/img/user2-160x160.jpg') }}" class="img-circle elevation-2"
                            alt="User Image">
                    </div>
                    <div class="info">
                        <a href="#" class="d-block">Bienvenue</a>
                    </div>
                </div>

                <!-- Navigation -->
                <nav class="mt-2">
                    <ul class="nav nav-pills nav-sidebar flex-column" role="menu" data-accordion="false">

                        <!-- Section : Analyse -->
                        <br>



                        <li class="nav-item">
                            <a href="{{ url('/statistics') }}"
                                class="nav-link {{ request()->is('statistics') ? 'active' : '' }}">
                                <i class="nav-icon fas fa-chart-bar"></i>
                                <p>Statistiques</p>
                            </a>
                        </li>

                        <!-- Section : Prédiction -->
                        <br>


                        <li class="nav-item">
                            <a href="{{ url('/') }}" class="nav-link {{ request()->is('/') ? 'active' : '' }}">
                                <i class="nav-icon fas fa-stethoscope"></i>
                                <p>Prédiction AVC</p>
                            </a>
                        </li>
                        <br>

                        <!-- Section : Administration -->


                        {{-- Dashboard --}}

                        <li class="nav-item">
                            <a href="{{ url('/dashboard') }}"
                                class="nav-link {{ request()->is('dashboard') ? 'active' : '' }}">
                                <i class="nav-icon fas fa-tachometer-alt"></i>
                                <p>Tableau de bord</p>
                            </a>
                        </li>
                        <br>

                        {{-- Utilisateurs --}}

                        <li class="nav-item">
                            <a href="{{ url('/analysis') }}"
                                class="nav-link {{ request()->is('analysis') ? 'active' : '' }}">
                                <i class="nav-icon fas fa-chart-line"></i>
                                <p>Analysis</p>
                            </a>
                        </li>

                        <br>

                        {{-- contact --}}
                        <li class="nav-item">
                            <a href="{{ url('/contact') }}"
                                class="nav-link {{ request()->is('contact') ? 'active' : '' }}">
                                <i class="nav-icon fas fa-envelope"></i>
                                <p>Contact</p>
                            </a>
                        </li>
                        <br>

                        <!-- Section : À propos -->


                        <li class="nav-item">
                            <a href="{{ url('/about') }}"
                                class="nav-link {{ request()->is('about') ? 'active' : '' }}">
                                <i class="nav-icon fas fa-info-circle"></i>
                                <p>À propos</p>
                            </a>
                        </li>

                    </ul>
                </nav>
            </div>
            <!-- /.sidebar -->
        </aside>


        <!-- Content Wrapper. Contains page content -->
        <!-- Content Section -->
        @yield('content')
        <!-- /.content-wrapper -->
        <!-- Footer -->
        <footer class="main-footer">
            <div class="float-right d-none d-sm-block"><b>Version</b> 3.2.0</div>
            <strong>Copyright &copy; 2014-2021
                <a href="https://adminlte.io">AdminLTE.io</a>.</strong>
            All rights reserved.
        </footer>

        <!-- end footer -->

        <!-- Control Sidebar -->
        <aside class="control-sidebar control-sidebar-dark">
            <!-- Add Content Here -->
        </aside>
        <!-- /.control-sidebar -->
    </div>
    <!-- ./wrapper -->

    <!-- jQuery -->
    <script src="{{ asset('plugins/jquery/jquery.min.js') }}"></script>
    <!-- Bootstrap 4 -->
    <script src="{{ asset('plugins/bootstrap/js/bootstrap.bundle.min.js') }}"></script>
    <!-- ChartJS -->
    <script src="{{ asset('plugins/chart.js/Chart.min.js') }}"></script>
    <!-- AdminLTE App -->
    <script src="{{ asset('dist/js/adminlte.min.js') }}"></script>
    <!-- AdminLTE for demo purposes -->
    <script src="{{ asset('dist/js/demo.js') }}"></script>
    <!-- Page specific script -->
    <script>
        $(function() {
            /* ChartJS
             * -------
             * Here we will create a few charts using ChartJS
             */

            //--------------
            //- AREA CHART -
            //--------------

            // Get context with jQuery - using jQuery's .get() method.
            var areaChartCanvas = $("#areaChart").get(0).getContext("2d");

            var areaChartData = {
                labels: [
                    "January",
                    "February",
                    "March",
                    "April",
                    "May",
                    "June",
                    "July",
                ],
                datasets: [{
                        label: "Digital Goods",
                        backgroundColor: "rgba(60,141,188,0.9)",
                        borderColor: "rgba(60,141,188,0.8)",
                        pointRadius: false,
                        pointColor: "#3b8bba",
                        pointStrokeColor: "rgba(60,141,188,1)",
                        pointHighlightFill: "#fff",
                        pointHighlightStroke: "rgba(60,141,188,1)",
                        data: [28, 48, 40, 19, 86, 27, 90],
                    },
                    {
                        label: "Electronics",
                        backgroundColor: "rgba(210, 214, 222, 1)",
                        borderColor: "rgba(210, 214, 222, 1)",
                        pointRadius: false,
                        pointColor: "rgba(210, 214, 222, 1)",
                        pointStrokeColor: "#c1c7d1",
                        pointHighlightFill: "#fff",
                        pointHighlightStroke: "rgba(220,220,220,1)",
                        data: [65, 59, 80, 81, 56, 55, 40],
                    },
                ],
            };

            var areaChartOptions = {
                maintainAspectRatio: false,
                responsive: true,
                legend: {
                    display: false,
                },
                scales: {
                    xAxes: [{
                        gridLines: {
                            display: false,
                        },
                    }, ],
                    yAxes: [{
                        gridLines: {
                            display: false,
                        },
                    }, ],
                },
            };

            // This will get the first returned node in the jQuery collection.
            new Chart(areaChartCanvas, {
                type: "line",
                data: areaChartData,
                options: areaChartOptions,
            });

            //-------------
            //- LINE CHART -
            //--------------
            var lineChartCanvas = $("#lineChart").get(0).getContext("2d");
            var lineChartOptions = $.extend(true, {}, areaChartOptions);
            var lineChartData = $.extend(true, {}, areaChartData);
            lineChartData.datasets[0].fill = false;
            lineChartData.datasets[1].fill = false;
            lineChartOptions.datasetFill = false;

            var lineChart = new Chart(lineChartCanvas, {
                type: "line",
                data: lineChartData,
                options: lineChartOptions,
            });

            //-------------
            //- DONUT CHART -
            //-------------
            // Get context with jQuery - using jQuery's .get() method.
            var donutChartCanvas = $("#donutChart").get(0).getContext("2d");
            var donutData = {
                labels: ["Chrome", "IE", "FireFox", "Safari", "Opera", "Navigator"],
                datasets: [{
                    data: [700, 500, 400, 600, 300, 100],
                    backgroundColor: [
                        "#f56954",
                        "#00a65a",
                        "#f39c12",
                        "#00c0ef",
                        "#3c8dbc",
                        "#d2d6de",
                    ],
                }, ],
            };
            var donutOptions = {
                maintainAspectRatio: false,
                responsive: true,
            };
            //Create pie or douhnut chart
            // You can switch between pie and douhnut using the method below.
            new Chart(donutChartCanvas, {
                type: "doughnut",
                data: donutData,
                options: donutOptions,
            });

            //-------------
            //- PIE CHART -
            //-------------
            // Get context with jQuery - using jQuery's .get() method.
            var pieChartCanvas = $("#pieChart").get(0).getContext("2d");
            var pieData = donutData;
            var pieOptions = {
                maintainAspectRatio: false,
                responsive: true,
            };
            //Create pie or douhnut chart
            // You can switch between pie and douhnut using the method below.
            new Chart(pieChartCanvas, {
                type: "pie",
                data: pieData,
                options: pieOptions,
            });

            //-------------
            //- BAR CHART -
            //-------------
            var barChartCanvas = $("#barChart").get(0).getContext("2d");
            var barChartData = $.extend(true, {}, areaChartData);
            var temp0 = areaChartData.datasets[0];
            var temp1 = areaChartData.datasets[1];
            barChartData.datasets[0] = temp1;
            barChartData.datasets[1] = temp0;

            var barChartOptions = {
                responsive: true,
                maintainAspectRatio: false,
                datasetFill: false,
            };

            new Chart(barChartCanvas, {
                type: "bar",
                data: barChartData,
                options: barChartOptions,
            });

            //---------------------
            //- STACKED BAR CHART -
            //---------------------
            var stackedBarChartCanvas = $("#stackedBarChart")
                .get(0)
                .getContext("2d");
            var stackedBarChartData = $.extend(true, {}, barChartData);

            var stackedBarChartOptions = {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    xAxes: [{
                        stacked: true,
                    }, ],
                    yAxes: [{
                        stacked: true,
                    }, ],
                },
            };

            new Chart(stackedBarChartCanvas, {
                type: "bar",
                data: stackedBarChartData,
                options: stackedBarChartOptions,
            });
        });
    </script>
</body>

</html>
