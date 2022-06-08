# ARCHITECTURE_DESIGN

1. Extractor
   1. 실시간 스트리밍 데이터 (Raw: Twitter)
   2. OpenAPI 데이터 
   3. fake customer 데이터 (python. faker module)
   4. fake IoT 데이터 (PubNub)
2. Staging Area (OnLine Transaction Processing)
   1. Transformer
      1. Spark 등을 통해 Data를 DW에 맞게 변형
   2. 
3. Loader
   1. 충분히 변형된 Data를 DW에 전달
4. Data WareHouse
5. OnLine Analytical Processing
   1. 