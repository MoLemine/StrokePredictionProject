<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Prediction extends Model
{
    //
    protected $fillable = ['name', 'email', 'phone', 'gender', 'result',
        'hypertension', 'heart_disease', 'ever_married', 'work_type',
        'Residence_type', 'smoking_status', 'age', 'bmi', 'glucose'];

}
