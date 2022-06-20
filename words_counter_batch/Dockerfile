FROM python:3-slim
WORKDIR /usr/src
COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt
WORKDIR /usr/src/app
COPY *.py ./
CMD [ "python3", "words_counter_batch.py" ]