@extends('layouts.dashboard')

@section('content')
<div class="content-wrapper">
    <!-- En-tête -->
    <section class="content-header">
    <div class="container-fluid">
        <div class="row align-items-center mb-3">
            <div class="col-md-1 text-center">
                <i class="fas fa-brain fa-3x text-primary"></i>
            </div>
            <div class="col-md-11">
                <h1 class="mb-1"> <strong>Accident Vasculaire Cérébral (AVC)</strong></h1>
                <p class="text-muted">
                     est une urgence médicale causée par une interruption du flux sanguin vers le cerveau. 
                    Grâce à ce tableau de bord, vous pouvez consulter les statistiques globales issues des prédictions effectuées, 
                    et analyser les facteurs de risque identifiés.
                </p>
            </div>
        </div>

        
    </div>
</section>


    <!-- Contenu principal -->
    <section class="content">
        <div class="container-fluid">
            <!-- AVC par sexe -->
            <div class="row mt-3">
                <div class="col-md-6">
                    <div class="info-box bg-secondary">
                        <span class="info-box-icon"><i class="fas fa-mars"></i></span>
                        <div class="info-box-content">
                            <span class="info-box-text">AVC chez les hommes</span>
                            <span class="info-box-number">{{ $maleStroke }}</span>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="info-box bg-secondary">
                        <span class="info-box-icon"><i class="fas fa-venus"></i></span>
                        <div class="info-box-content">
                            <span class="info-box-text">AVC chez les femmes</span>
                            <span class="info-box-number">{{ $femaleStroke }}</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <!-- Total prédictions -->
                {{-- <div class="col-md-4">
                    <div class="info-box bg-info">
                        <span class="info-box-icon"><i class="fas fa-notes-medical"></i></span>
                        <div class="info-box-content">
                            <span class="info-box-text">Total des prédictions</span>
                            <span class="info-box-number">{{ $total }}</span>
                            <a href="{{ url('/') }}" class="small-box-footer text-white">Faire une prédiction <i class="fas fa-arrow-circle-right"></i></a>
                        </div>
                    </div>
                </div> --}}

                <!-- Total hommes / femmes -->
                <div class="col-md-6">
                    <div class="info-box bg-primary">
                        <span class="info-box-icon"><i class="fas fa-male"></i></span>
                        <div class="info-box-content">
                            <span class="info-box-text">Total Hommes</span>
                            <span class="info-box-number">{{ $maleCount }}</span>
                        </div>
                    </div>
                    <div class="info-box bg-pink">
                        <span class="info-box-icon"><i class="fas fa-female"></i></span>
                        <div class="info-box-content">
                            <span class="info-box-text">Total Femmes</span>
                            <span class="info-box-number">{{ $femaleCount }}</span>
                        </div>
                    </div>
                </div>

                <!-- AVC / Non AVC -->
                <div class="col-md-6">
                    <div class="info-box bg-danger">
                        <span class="info-box-icon"><i class="fas fa-procedures"></i></span>
                        <div class="info-box-content">
                            <span class="info-box-text">Cas d’AVC</span>
                            <span class="info-box-number">{{ $stroke }}</span>
                        </div>
                    </div>
                    <div class="info-box bg-success">
                        <span class="info-box-icon"><i class="fas fa-heartbeat"></i></span>
                        <div class="info-box-content">
                            <span class="info-box-text">Pas d’AVC</span>
                            <span class="info-box-number">{{ $noStroke }}</span>
                        </div>
                    </div>
                </div>
            </div>

            

        </div>
    </section>
</div>
@endsection
