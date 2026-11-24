namespace JKF.OrderAgent;
using Microsoft.Sales.Document;
tableextension 50371 "JKF Agent Sales Header" extends "Sales Header"
{
    fields
    {
        field(50370; "JKF Agent Draft"; Boolean)
        {
            Caption = 'Created by order agent';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
