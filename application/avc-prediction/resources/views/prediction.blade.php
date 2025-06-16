<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Résultat de la prédiction</title>
    @include('adminlte::head')
    <style>
        .content-wrapper {
            background: #f4f6f9;
        }
        .card {
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        }
        .card-header {
            font-size: 1.1rem;
            font-weight: 600;
            padding: 8px 16px;
            background: #ffffff;
            border-bottom: 1px solid #e9ecef;
        }
        .card-body {
            padding: 12px;
        }
        table {
            font-size: 0.85rem;
            margin-bottom: 0;
        }
        th, td {
            padding: 6px 10px;
            border-bottom: 1px solid #e9ecef;
        }
        th {
            background: #f8f9fa;
            text-transform: uppercase;
            font-size: 0.8rem;
            letter-spacing: 0.05em;
        }
        .prediction {
            font-size: 1rem;
            font-weight: 600;
            text-align: center;
            padding: 10px;
            border-radius: 6px;
            color: #fff;
            margin: 12px 0;
            background-color: {{ $prediction == 1 ? '#dc3545' : '#28a745' }};
        }
        .charts-section {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 10px;
        }
        .chart-container {
            max-height: 150px;
        }
        .analytics-section {
            font-size: 0.85rem;
            color: #495057;
        }
        .analytics-section ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        .analytics-section li {
            margin-bottom: 4px;
        }
        .back-link a {
            font-size: 0.85rem;
            color: #007bff;
            text-decoration: none;
            padding: 6px 12px;
            border-radius: 6px;
            display: inline-flex;
            align-items: center;
        }
        .back-link a:hover {
            background: #e7f1ff;
            color: #0056b3;
        }
        @media (max-width: 768px) {
            .card-header {
                font-size: 1rem;
            }
            table {
                font-size: 0.8rem;
            }
            th, td {
                padding: 5px 8px;
            }
            .prediction {
                font-size: 0.9rem;
                padding: 8px;
            }
            .charts-section {
                grid-template-columns: 1fr;
            }
            .chart-container {
                max-height: 120px;
            }
        }
    </style>
</head>
<body class="hold-transition sidebar-mini layout-fixed">
<div class="wrapper">
    @include('adminlte::page')

    <section class="content">
        <div class="container-fluid py-3">
            <!-- Card pour les informations du patient -->
            <div class="card">
                <div class="card-header">
                    Résumé de la prédiction
                </div>
                <div class="card-body">
                    <table class="table">
                        <tbody>
                            <tr><th><i class="fas fa-user"></i> Nom</th><td>{{ $data->name ?? '-' }}</td></tr>
                            <tr><th><i class="fas fa-envelope"></i> Email</th><td>{{ $data->email ?? '-' }}</td></tr>
                            <tr><th><i class="fas fa-phone"></i> Téléphone</th><td>{{ $data->phone ?? '-' }}</td></tr>
                            <tr><th><i class="fas fa-venus-mars"></i> Genre</th><td>{{ $data->gender ?? '-' }}</td></tr>
                            <tr><th><i class="fas fa-heartbeat"></i> Hypertension</th><td>{{ $data->hypertension ?? '-' }}</td></tr>
                            <tr><th><i class="fas fa-heart"></i> Maladie cardiaque</th><td>{{ $data->heart_disease ?? '-' }}</td></tr>
                            <tr><th><i class="fas fa-ring"></i> Déjà marié(e)</th><td>{{ $data->ever_married ?? '-' }}</td></tr>
                            <tr><th><i class="fas fa-briefcase"></i> Travail</th><td>{{ $data->work_type ?? '-' }}</td></tr>
                            <tr><th><i class="fas fa-home"></i> Résidence</th><td>{{ $data->Residence_type ?? '-' }}</td></tr>
                            <tr><th><i class="fas fa-smoking"></i> Statut tabagique</th><td>{{ $data->smoking_status ?? '-' }}</td></tr>
                            <tr><th><i class="fas fa-calendar-alt"></i> Âge</th><td>{{ $data->age ?? '-' }}</td></tr>
                            <tr><th><i class="fas fa-weight"></i> IMC</th><td>{{ $data->bmi ?? '-' }}</td></tr>
                            <tr><th><i class="fas fa-tint"></i> Glucose</th><td>{{ $data->glucose ?? '-' }}</td></tr>
                        </tbody>
                    </table>
                    <div class="prediction">{{ $prediction == 1 ? 'Stroke' : 'No Stroke' }}</div>
                </div>
            </div>

            <!-- Card pour les graphiques -->
            <div class="card">
                <div class="card-header">
                    Analyses Visuelles
                </div>
                <div class="card-body">
                    <div class="charts-section">
                        <div class="chart-container">{!! $genderChart->renderHtml() !!}</div>
                        <div class="chart-container">{!! $predictionChart->renderHtml() !!}</div>
                        <div class="chart-container">{!! $bmiChart->renderHtml() !!}</div>
                    </div>
                </div>
            </div>

            <!-- Card pour les analyses statistiques -->
            <div class="card">
                <div class="card-header">
                    Statistiques
                </div>
                <div class="card-body">
                    <div class="analytics-section">
                        <ul>
                            <li><strong>Âge moyen des patients :</strong> {{ round($analytics['avg_age'], 1) }} ans</li>
                            <li><strong>Pourcentage de prédictions Stroke :</strong> {{ round($analytics['stroke_percentage'], 1) }}%</li>
                            <li><strong>Nombre de patients avec hypertension :</strong> {{ $analytics['hypertension_count'] }}</li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Lien de retour -->
            <div class="back-link">
                <a href="{{ url('/') }}"><i class="fas fa-arrow-left"></i> Retour au formulaire</a>
            </div>
        </div>
    </section>
</div>

<!-- Scripts pour AdminLTE et Chart.js -->
@include('adminlte::scripts')
@section('js')
    {!! $genderChart->renderChartJsLibrary() !!}
    {!! $genderChart->renderJs() !!}
    {!! $predictionChart->renderJs() !!}
    {!! $bmiChart->renderJs() !!}
@endsection
</body>
</html>