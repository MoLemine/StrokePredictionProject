<?php

namespace App\Http\Controllers;

use App\Models\Prediction;
use Illuminate\Http\Request;

class PredictionController extends Controller
{

    public function index()
    {
        $total = Prediction::count();
        $stroke = Prediction::where('result', 1)->count();
        $noStroke = Prediction::where('result', 0)->count();
        $maleCount = Prediction::where('gender', 'Male')->count();
        $femaleCount = Prediction::where('gender', 'Female')->count();
        $maleStroke = Prediction::where('gender', 'Male')->where('result', 1)->count();
        $femaleStroke = Prediction::where('gender', 'Female')->where('result', 1)->count();

        return view('dashboard', compact(
            'total',
            'stroke',
            'noStroke',
            'maleCount',
            'femaleCount',
            'maleStroke',
            'femaleStroke'
        ));
    }
    public function predict(Request $request)
    {
        $request->validate([
            'name' => 'required',
            'email' => 'required|email',
            'age' => 'required|numeric',
            'bmi' => 'required|numeric',
            'glucose' => 'required|numeric',
        ]);

        // 1. Enregistrement initial sans le résultat
        $prediction_record = Prediction::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'gender' => $request->gender,
            'hypertension' => $request->hypertension,
            'heart_disease' => $request->heart_disease,
            'ever_married' => $request->ever_married,
            'work_type' => $request->work_type,
            'Residence_type' => $request->Residence_type,
            'smoking_status' => $request->smoking_status,
            'age' => $request->age,
            'bmi' => $request->bmi,
            'glucose' => $request->glucose,
        ]);

        // 2. Appel du script R
        $R_PATH = '"C:\\Program Files\\R\\R-4.5.0\\bin\\Rscript.exe"';
        $SCRIPT_PATH = '"C:\\Users\\MoLemine\\Documents\\StrokePrediction\\predict_avc.R"';

        $args = [
            escapeshellarg($request->gender),
            escapeshellarg($request->hypertension),
            escapeshellarg($request->heart_disease),
            escapeshellarg($request->ever_married),
            escapeshellarg($request->work_type),
            escapeshellarg($request->Residence_type),
            escapeshellarg($request->smoking_status),
            escapeshellarg($request->age),
            escapeshellarg($request->bmi),
            escapeshellarg($request->glucose)
        ];

        $command = "$R_PATH $SCRIPT_PATH " . implode(' ', $args);
        exec($command, $output, $status);

        $prediction_result = ($status === 0 && !empty($output)) ? trim(implode('', $output)) : 'Erreur';

        // Convertir en 0 ou 1
        $result_binary = $prediction_result === 'Stroke' ? 1 : 0;

        // 3. Mise à jour du résultat dans la base
        $prediction_record->update(['result' => $result_binary]);

        // 4. Affichage du résultat avec toutes les données
        return view('result', [
            'prediction' => $prediction_result,
            'data' => $prediction_record
        ]);
    }
    public function eda()
    {
        return view('eda');
    }
}
