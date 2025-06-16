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
        // 1. Validation des champs
        $request->validate([
            'name' => 'required',
            'email' => 'required|email',
            'age' => 'required|numeric',
            'bmi' => 'required|numeric',
            'glucose' => 'required|numeric',
            'gender' => 'required|in:Male,Female,Other',
            'hypertension' => 'required|in:No,Yes',
            'heart_disease' => 'required|in:No,Yes',
            'ever_married' => 'required|in:No,Yes',
            'work_type' => 'required|in:Private,Self-employed,Govt_job,Children,Never_worked',
            'Residence_type' => 'required|in:Urban,Rural',
            'smoking_status' => 'required|in:never smoked,formerly smoked,smokes,Unknown',
        ]);

        // 2. Enregistrement initial dans la base (sans le résultat)
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

        // 3. Préparation de la commande R
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

        // 4. Traitement du résultat
        $prediction_result = ($status === 0 && !empty($output))
            ? trim(implode('', $output))
            : null;

        // dd($command, $output, $status , $prediction_result);

        if ($prediction_result === '0') {
            $label = 'Pas d\'AVC';
            $result_binary = 0;
        } elseif ($prediction_result === '1') {
            $label = 'AVC';
            $result_binary = 1;
        } else {
            $label = 'Erreur lors de la prédiction';
            $result_binary = null;
        }

        // 5. Mise à jour du résultat en base
        $prediction_record->update(['result' => $result_binary]);
        // dd($prediction_record);

        // 6. Retour à la vue avec les données complètes
        return view('result', [
            'prediction' => $label,
            'data' => $prediction_record
        ]);
    }

    public function eda()
    {
        return view('eda');
    }
}
