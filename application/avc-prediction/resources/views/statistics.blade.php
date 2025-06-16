@extends('layouts.dashboard')

@section('content')
<div class="content-wrapper">
    <!-- Content Header -->
    <section class="content-header">
        <div class="container-fluid">
            <h1 class="text-center">Visualisations AVC</h1>
        </div>
    </section>

    <!-- Main content -->
    <section class="content">
        <div class="container-fluid">
            <div class="row">
                @php
                    $charts = [
                        'age_vs_stroke' => 'Âge vs AVC',
                        'bmi_vs_stroke' => 'IMC vs AVC',
                        'avg_glucose_level_vs_stroke' => 'Glucose moyen vs AVC',
                        'gender_vs_stroke' => 'Genre vs AVC',
                        'heart_disease_vs_stroke' => 'Maladie cardiaque vs AVC',
                        'hypertension_vs_stroke' => 'Hypertension vs AVC',
                        'marital_status_vs_stroke' => 'Statut marital vs AVC',
                        'smoking_status_vs_stroke' => 'Tabagisme vs AVC',
                        'work_type_vs_stroke' => 'Travail vs AVC',
                        'distribution_stroke' => 'Distribution des AVC',
                        'age_vs_bmi' => 'Nuage de points Âge vs IMC (coloré par AVC)',
                    ];
                @endphp

                @foreach ($charts as $filename => $title)
                <div class="col-md-6">
                    <div class="card card-outline card-primary">
                        <div class="card-header">
                            <h3 class="card-title">{{ $title }}</h3>
                            <div class="card-tools">
                                <button type="button" class="btn btn-tool" data-card-widget="collapse">
                                    <i class="fas fa-minus"></i>
                                </button>
                                <button type="button" class="btn btn-tool" data-card-widget="remove">
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>
                        </div>
                        <div class="card-body text-center">
                            <img src="{{ asset('figures/' . $filename . '.png') }}" class="img-fluid" alt="{{ $title }}">
                        </div>
                    </div>
                </div>
                @endforeach

            </div>
        </div>
    </section>
</div>
@endsection
