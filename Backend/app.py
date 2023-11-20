import openai
import yfinance as yf
import pandas as pd
from langchain_experimental.agents.agent_toolkits.pandas.base import create_pandas_dataframe_agent
from langchain.llms import OpenAI
import os
from flask import Flask, jsonify, request
from flask_cors import CORS
from dotenv import load_dotenv

load_dotenv()

# os.environ['OPENAI_API_KEY']

key = os.getenv('OPENAI_API_KEY')


app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})



def relret(df):
    rel = df.pct_change()
    cumret = (1 + rel).cumprod() - 1
    cumret = cumret.fillna(0)
    return cumret

# Store stock data received from '/stock_data'
stock_data = None
tickers_num = None
start_date_data = None
end_date_data = None
df_data = None

@app.route('/stock_data', methods=['POST'])
def get_stock_data():
    try:
        global stock_data, tickers_num, start_date_data, end_date_data, df_data
        
        tickers = request.json.get('tickers')
        start_date = request.json.get('start_time')
        end_date = request.json.get('end_time')
        # print(tickers)
        tickers_num = tickers
        start_date_data = start_date
        end_date_data = end_date
        print(tickers_num, start_date_data, end_date_data)
        data = {}
        for ticker in tickers:
            df = relret(yf.download(ticker, start=start_date, end=end_date)['Adj Close'].round(2))

            data[ticker] = df.tolist()
        
        stock_data = data
        df_data = relret(yf.download(tickers, start=start_date, end=end_date)['Adj Close'].round(2))
        print(data)
        return jsonify(data)
    
    except Exception as err:
        print(err)
        return jsonify({"error": str(err)})

@app.route('/chat', methods=['POST'])
def chat():
    # print('ye function mei aaya atleast')
    try:
        global stock_data, start_date_data, end_date_data, df_data
        
        request_data = request.get_json()
        quote = request_data.get('quote', '')
        print(quote, stock_data, start_date_data, end_date_data, tickers_num)

        if len(tickers_num) >= 1:
            # print('yaha tal aaya')
            try:
                # print("Query run karo pls!!!")
                # print(df_data)
                agent = create_pandas_dataframe_agent(OpenAI(temperature=0.3), pd.DataFrame(df_data), verbose = True)
                answer = agent.run(quote + ".give name of the stock")
                response = {"message": answer}
                return jsonify(response)
            except Exception as err:
                print(err)
                return jsonify({'error': str(err)})
    except Exception as er:
        return jsonify({'error': str(er)})

@app.route('/advice', methods=['POST'])
def chat_advice():
    openai.api_key = key
    data = request.get_json()
    credit_amount = float(data.get('creditAmount', 0))
    debit_amount = float(data.get('debitAmount', 0))
    user_query = data.get('userQuery', '')
    print(credit_amount, debit_amount, user_query)
        
    response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a financial advisor."},
                {"role": "user", "content": user_query + ", this is the credit " + str(credit_amount) + " this is the debit amount "+ str(debit_amount) + " this is in rupees " + " give only 3 points "},
            ],
        )
        
    advice = response.choices[0].message['content']
    print(advice)
    # advice = "hello"
        
    return jsonify({'advice': advice})

if __name__ == '__main__':
    app.run(debug=True)
