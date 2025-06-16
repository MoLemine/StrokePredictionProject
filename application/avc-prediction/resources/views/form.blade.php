@extends('layouts.dashboard')

@section('content')
<div class="content-wrapper">
  

  <section class="content">
    <div class="container-fluid">
      <div class="card card-primary shadow">
        <div class="card-header">
          <h3 class="card-title">Remplissez les informations du patient</h3>
        </div>
        <form method="POST" action="{{ route('predict') }}">
          @csrf
          <div class="card-body row">
            <div class="col-md-6">
              <div class="form-group">
                <label>Nom complet</label>
                <input type="text" class="form-control" name="name" required>
              </div>

              <div class="form-group">
                <label>Email</label>
                <input type="email" class="form-control" name="email" required>
              </div>

              <div class="form-group">
                <label>Téléphone</label>
                <input type="text" class="form-control" name="phone">
              </div>

              <div class="form-group">
                <label>Genre</label>
                <select class="form-control" name="gender">
                  <option>Male</option>
                  <option>Female</option>
                  <option>Other</option>
                </select>
              </div>

              <div class="form-group">
                <label>Hypertension</label>
                <select class="form-control" name="hypertension">
                  <option>No</option>
                  <option>Yes</option>
                </select>
              </div>

              <div class="form-group">
                <label>Maladie cardiaque</label>
                <select class="form-control" name="heart_disease">
                  <option>No</option>
                  <option>Yes</option>
                </select>
              </div>
            </div>

            <div class="col-md-6">
              <div class="form-group">
                <label>Déjà marié(e)</label>
                <select class="form-control" name="ever_married">
                  <option>No</option>
                  <option>Yes</option>
                </select>
              </div>

              <div class="form-group">
                <label>Type d'emploi</label>
                <select class="form-control" name="work_type">
                  <option>Private</option>
                  <option>Self-employed</option>
                  <option>Govt_job</option>
                  <option>Children</option>
                  <option>Never_worked</option>
                </select>
              </div>

              <div class="form-group">
                <label>Type de résidence</label>
                <select class="form-control" name="Residence_type">
                  <option>Urban</option>
                  <option>Rural</option>
                </select>
              </div>

              <div class="form-group">
                <label>Statut tabagique</label>
                <select class="form-control" name="smoking_status">
                  <option>never smoked</option>
                  <option>formerly smoked</option>
                  <option>smokes</option>
                  <option>Unknown</option>
                </select>
              </div>

              <div class="form-group">
                <label>Âge</label>
                <input type="number" class="form-control" name="age" step="0.1" required>
              </div>

              <div class="form-group">
                <label>IMC</label>
                <input type="number" class="form-control" name="bmi" step="0.1" required>
              </div>

              <div class="form-group">
                <label>Glucose moyen</label>
                <input type="number" class="form-control" name="glucose" step="0.1" required>
              </div>
            </div>
          </div>

          <div class="card-footer text-center">
            <button type="submit" class="btn btn-primary">Prédire AVC</button>
          </div>
        </form>
      </div>
    </div>
  </section>
</div>
@endsection
