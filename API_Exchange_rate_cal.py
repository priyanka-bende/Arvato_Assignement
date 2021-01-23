# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.

from flask import jsonify



import markdown
import os
import shelve
import time
import json
import requests


from flask import Flask,g
from flask_restful import Resource,Api,abort, fields, marshal_with,reqparse
from datetime import datetime


app = Flask(__name__)
api = Api(app)
#app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'


# api_get_arg= reqparse.RequestParser()
# api_get_arg.add_argument("to_curr", type=str, help="To_Currency is required", required=True)
# api_get_arg.add_argument("From_Curr", type=str, help="From_Curr is required", required=True)
# api_get_arg.add_argument("Amount", type=int, help="Amount is required", required=True)


def abort_if_mandatory_param_is_missing(to_curr,amount):
    #frm_curr_len=len(frm_curr)
    to_curr_len = len(to_curr)
    amount_type = type(amount)
    # if frm_curr_len!= 3:
    #     abort(400,message="frm_curr parameter should contain 3 char")
    #     abort()
    if to_curr_len!= 3 :
        abort(400, message="to_curr parameter should contain 3 char",type="invalid input")

    if amount<=0:
        abort(400,message="Amount is incorrect",type="invalid input")

    if  amount_type!=int:
        abort(400, message="Amount is incorrect")



def fetch_currency_rate(to_curr):

    if to_curr=="":
        return 400,"request can not be processed please specify teh currency"
    uri= "http://data.fixer.io/api/latest?symbols="+to_curr+"&access_key=b9603b91873ab4a1083da7423b8b0c0f"

    print(uri)

    r= requests.get(uri)
    files=r.json()
    print(files)
    status=r.status_code
    success=str(files["success"])
    print(success)


    if success =="True":
        rate = get_actual_rate(files,to_curr)
        print(rate)
        return rate,200
    else:
        err_info,type=fetch_error_detail(files)
        return err_info,type

def fetch_error_detail(output_json):
    error=output_json["error"]
    type=error["type"]
    info=error["info"]
    #print(error)
    return info,type
def get_actual_rate(files,to_curr):
    exchande_rate_detail = files["rates"]
    #print(exchande_rate_detail)
    rate = exchande_rate_detail[to_curr]
    return rate

def get_calculate_currency(exchange_rate,amount):
    converted_rate=amount*exchange_rate
    return converted_rate

def get_output_josn(to_curr,calculated_value,amount,exchng_rate):
    x='{}'
    tstamp = datetime.now()
    json_obj = json.loads(x)

    # type(tstamp)
    json_obj['Timestamp'] = str(tstamp)

    json_obj['From_Curr'] = "EUR"
    json_obj['To_Curr'] = to_curr
    json_obj['Amount']=amount
    json_obj['exchange_rate']=exchng_rate

    json_obj['calculated_Amount'] = calculated_value

    #ret_obj= f'{{"Timestamp" : {json_obj.Timestamp}}}'
    ret_obj= json.dumps(json_obj,default=encoder_json,indent=2)

    return json_obj

def encoder_json(json_obj):
    return {'Timestamp':json_obj.Timestamp,'From_Curr':json_obj.From_Curr,'To_Curr':json_obj.To_Curr,'Amount':json_obj.Amount,'exchange_rate':json_obj.exchange_rate}

class API_Assignment(Resource):
    def get(self,to_curr,amount):
        amount= int(amount)

        to_curr=to_curr.upper()
        abort_if_mandatory_param_is_missing(to_curr,amount)
        externa_api_response,code = fetch_currency_rate(to_curr)
        if code!=200:
            abort(400, message=externa_api_response,type=code)
        else:
            calculated_value= get_calculate_currency(externa_api_response,amount)
            ouput_json_obj= get_output_josn(to_curr,calculated_value,amount,externa_api_response)
            #data=json.dumps(ouput_json_obj)
            #data=json.loads(ouput_json_obj)
        return ouput_json_obj


api.add_resource(API_Assignment,"/apiassignment/EUR/<to_curr>/<int:amount>/")


if __name__ == "__main__":
	app.run(debug=True)
