@extends('layouts.dashboard')

@section('content')
    <div class="content-wrapper">


        <section class="content">
            <div class="container-fluid">
                <div class="card shadow">
                    <div class="alert {{ $prediction == 1 ? 'alert-danger' : 'alert-success' }}" role="alert"
                        style="font-size: 1.3rem;">
                        <strong>Résultat de la prédiction :</strong> {{ $prediction == 1 ? 'Stroke' : 'No Stroke' }}
                    </div>


                    <div class="card-body">
                        <table class="table table-bordered table-striped">
                            <tbody>
                                <tr>
                                    <th><i class="fas fa-user"></i> Nom</th>
                                    <td>{{ $data->name ?? '-' }}</td>
                                </tr>
                                <tr>
                                    <th><i class="fas fa-envelope"></i> Email</th>
                                    <td>{{ $data->email ?? '-' }}</td>
                                </tr>
                                <tr>
                                    <th><i class="fas fa-phone"></i> Téléphone</th>
                                    <td>{{ $data->phone ?? '-' }}</td>
                                </tr>
                                <tr>
                                    <th><i class="fas fa-venus-mars"></i> Genre</th>
                                    <td>{{ $data->gender ?? '-' }}</td>
                                </tr>
                                <tr>
                                    <th><i class="fas fa-heartbeat"></i> Hypertension</th>
                                    <td>{{ $data->hypertension ?? '-' }}</td>
                                </tr>
                                <tr>
                                    <th><i class="fas fa-heart"></i> Maladie cardiaque</th>
                                    <td>{{ $data->heart_disease ?? '-' }}</td>
                                </tr>
                                <tr>
                                    <th><i class="fas fa-ring"></i> Déjà marié(e)</th>
                                    <td>{{ $data->ever_married ?? '-' }}</td>
                                </tr>
                                <tr>
                                    <th><i class="fas fa-briefcase"></i> Type d'emploi</th>
                                    <td>{{ $data->work_type ?? '-' }}</td>
                                </tr>
                                <tr>
                                    <th><i class="fas fa-home"></i> Résidence</th>
                                    <td>{{ $data->Residence_type ?? '-' }}</td>
                                </tr>
                                <tr>
                                    <th><i class="fas fa-smoking"></i> Tabagisme</th>
                                    <td>{{ $data->smoking_status ?? '-' }}</td>
                                </tr>
                                <tr>
                                    <th><i class="fas fa-calendar-alt"></i> Âge</th>
                                    <td>{{ $data->age ?? '-' }}</td>
                                </tr>
                                <tr>
                                    <th><i class="fas fa-weight"></i> IMC</th>
                                    <td>{{ $data->bmi ?? '-' }}</td>
                                </tr>
                                <tr>
                                    <th><i class="fas fa-tint"></i> Glucose</th>
                                    <td>{{ $data->glucose ?? '-' }}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
{{-- 
                    <div class="card-footer text-center">

                        <a href="{{ url('/') }}" class="btn btn-outline-primary mt-0">
                            <i class="fas fa-arrow-left"></i> Retour au formulaire
                        </a>
                    </div>
                     --}}
                </div>
            </div>
        </section>
    </div>
@endsection
