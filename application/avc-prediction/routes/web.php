<?php

use App\Http\Controllers\ChartController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PredictionController;

Route::get('/', function () {
    return view('form');
});
Route::post('/predict', [PredictionController::class, 'predict'])->name('predict');

Route::get('/statistics', function () {
    return view('statistics');
})->name('statistics');

Route::get('/about', function () {
    return view('about');
})->name('about');

Route::get('/dashboard', [PredictionController::class, 'index'])->name('dashboard');
Route::get('/analysis', [PredictionController::class, 'eda'])->name('analysis');

