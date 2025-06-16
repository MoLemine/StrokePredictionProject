@extends('layouts.dashboard')

@section('content')
<div class="content-wrapper">
    {{-- <section class="content-header">
        <div class="container-fluid">
            <h1>À propos du projet : Système de prédiction d’AVC</h1>
        </div>
    </section> --}}

    <section class="content">
        <div class="container-fluid">
            <div class="card card-info">
                <div class="card-header">
                    <h3 class="card-title">À propos du projet : Système de prédiction d’AVC</h3>
                </div>
                <div class="card-body">
                    {{-- <p>
                        Ce projet a pour objectif de concevoir et implémenter un système de prédiction des AVC (Accidents Vasculaires Cérébraux) en utilisant des techniques de machine learning.
                    </p> --}}
                    <h4>🎯 Objectifs :</h4>
                    <ul>
                        <li>Prédire la probabilité qu'un patient ait un AVC à partir de données médicales.</li>
                        <li>Proposer une interface conviviale pour les utilisateurs.</li>
                        
                    </ul>

                    <h4>🧠 Technologies utilisées :</h4>
                    <ul>
                        <li><strong>R</strong> : pour la modélisation et la prédiction avec un réseau de neurones.</li>
                        <li><strong>Laravel (PHP)</strong> : framework backend pour gérer les routes, contrôleurs et stockage MySQL.</li>
{{--                         <li><strong>AdminLTE</strong> : pour le design de l'interface utilisateur (tableaux de bord, graphiques, cartes).</li>
 --}}                        <li><strong>Chart.js</strong> et images matplotlib : pour la visualisation des analyses statistiques.</li>
                    </ul>

                    <h4>📁 Fonctionnalités :</h4>
                    <ul>
                        <li>Formulaire intelligent de saisie des données utilisateur et Affichage du résultat prediction (Stroke / NoStroke) .</li>
                        <li>Prédiction basée sur un modèle de réseau de neurones entraîné.</li>
                        <li>Visualisation des données et des résultats via des graphiques interactifs.</li>
                        <li>Stockage des données utilisateur et des résultats de prédiction dans une base de données MySQL.</li>
                    </ul>

                    <h4>👨‍💻 Réalisé par :</h4>
                    <ul>
                        <li>Mohamed Lemine Abdallahi Tah</li>
                        <li>Mariem Cheikhna Cheikh Mohamed El Mehdi</li>
                        <li>Boudah Mohamed Lemine Ahmedou El Mokhtar</li>
                    </ul>
                </div>
            </div>
        </div>
    </section>
</div>
@endsection
