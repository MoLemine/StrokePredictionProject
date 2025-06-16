@extends('layouts.dashboard')

@section('content')
    <div class="content-wrapper">
        <section class="content-header">
            <div class="container-fluid">
                <h1 class="mb-2">Analyse exploratoire des variables continues</h1>
                <p class="text-muted">
                    Cette section présente l’analyse statistique des variables continues liées à l’AVC, telles que l’âge, le
                    niveau de glucose et l’IMC.
                    Ces analyses permettent de mieux comprendre les relations et distributions de ces variables dans le
                    dataset.
                </p>
            </div>
            <!-- Résumé des découvertes -->
            <div class="card card-info">
                <div class="card-header">
                    <h3 class="card-title">Résumé des découvertes</h3>
                </div>
                <div class="card-body">
                    <ul>
                        <!-- Variables continues -->
                        <li><strong>L’âge</strong> est l’un des facteurs les plus corrélés à l’AVC. Les personnes âgées
                            présentent un risque nettement accru.</li>
                        <li><strong>Le taux moyen de glucose</strong> est plus élevé en moyenne chez les patients ayant subi
                            un AVC, bien que la corrélation reste modérée.</li>
                        <li><strong>L’IMC (bmi)</strong> est moins corrélé directement à l’AVC mais des valeurs extrêmes
                            (surpoids sévère) sont plus représentées dans les cas positifs.</li>


                        <!-- Variables catégorielles -->
                        <li><strong>Les patients hypertendus</strong> ont un taux d’AVC beaucoup plus élevé que ceux non
                            hypertendus.</li>
                        <li><strong>La présence d'une maladie cardiaque</strong> est également un indicateur important, avec
                            un taux d’AVC supérieur à la moyenne.</li>
                        <li><strong>Le statut marital</strong> montre que les personnes mariées sont plus à risque,
                            possiblement dû à leur âge plus avancé.</li>
                        <li><strong>Le genre</strong> influence légèrement la prédiction. Les hommes ont un taux d’AVC
                            légèrement supérieur.</li>
                        <li><strong>Le type de travail</strong> (notamment "Self-employed" et "Never_worked") a une
                            incidence non négligeable sur les prédictions d’AVC.</li>
                        <li><strong>Le statut tabagique</strong> influence les résultats, en particulier chez les anciens
                            fumeurs ("formerly smoked") et les fumeurs actifs ("smokes").</li>

                    </ul>
                </div>
            </div>

        </section>

        <section class="content">
            <div class="container-fluid">

                <!-- Analyse des variables continues -->
                <div class="card card-primary">
                    <div class="card-header">
                        <h3 class="card-title">Analyse des variables continues</h3>
                    </div>
                    <div class="card-body">
                        <p>
                             les relations entre les variables continues du dataset, notamment
                            <strong>l’âge</strong>,
                            <strong>le niveau moyen de glucose</strong> et <strong>l’IMC (bmi)</strong>.
                            La matrice de corrélation révèle une relation modérée entre l’âge et le BMI, tandis que le taux
                            de glucose est faiblement corrélé aux autres variables.
                            La boîte à moustaches permet d’identifier les valeurs aberrantes : on note des valeurs extrêmes
                            dans <strong>avg_glucose_level</strong> (souvent > 200)
                            et <strong>bmi</strong>, alors que la distribution de l’<strong>âge</strong> est plus homogène.
                        </p>
                        <div class="row">
                            <div class="col-md-6">
                                <img src="{{ asset('figures/matrice_correlation.png') }}" alt="Matrice de corrélation"
                                    class="img-fluid">
                            </div>
                            <div class="col-md-6">
                                <img src="{{ asset('figures/boite_moustaches.png') }}" alt="Boîte à moustaches"
                                    class="img-fluid">
                            </div>
                        </div>
                    </div>
                </div>


            </div>
        </section>
        <!-- Variables Catégorielles -->
        <section class="content">
            <div class="container-fluid">
                <div class="card card-warning">
                    <div class="card-header">
                        <h3 class="card-title">Analyse des variables catégorielles</h3>
                    </div>
                    <div class="card-body">
                        <p>
                            Les variables catégorielles sont des facteurs déterminants dans la prédiction des AVC. Voici un
                            aperçu de leur impact :
                        </p>

                        <ul>
                            <li><strong>Sexe :</strong> Les hommes et femmes présentent des taux d’AVC relativement
                                comparables, bien que de légères différences soient visibles selon l’âge.</li>
                            <li><strong>Statut marital :</strong> Les personnes mariées ont un taux d’AVC plus élevé. Cela
                                peut être lié à l’âge moyen plus avancé de cette catégorie.</li>
                            <li><strong>Hypertension et maladie cardiaque :</strong> Ces deux facteurs sont fortement
                                corrélés à l’apparition d’un AVC.</li>
                            <li><strong>Type de travail et statut tabagique :</strong> Ils ont un effet moins direct mais
                                influencent certains groupes d’âge.</li>
                        </ul>

                        <div class="text-center mt-4">
                            <img src="{{ asset('figures/variables_categorielles.png') }}" class="img-fluid rounded shadow"
                                alt="Analyse des variables catégorielles">
                        </div>

                        <p class="mt-4">
                            Cette figure regroupe les principales variables catégorielles et leur lien avec les cas d’AVC.
                            Elle permet d’identifier visuellement les groupes à risque.
                        </p>
                    </div>
                </div>
            </div>
        </section>


    </div>
@endsection
