
# Data-Warehousing-Sandbox

Data Warehouse를 Sandbox로 구현하여, Unit 단위 구축 및 테스트가 가능한 프레임워크 구축
2022 데이터베이스 시스템 및 특론 수업 (과학기술연합대학원대학교)

Author. 정현재 (presentj94@ust.ac.kr)

## 과제명: 빅데이터 기술을 이용한 데이터 분석 사례 구축 및 발표

## 주요 요구사항

1. Sample Dataset(자유)를 이용한 Data Warehouse 구축
   1. DW 기반 기술은 RDBMS, Hadoop, Spark, NoSQL 등 자유 선택
      1. RDBMS를 이용하여 DW 구축 시, 사전 정규화가 된 데이터 사용 가능
         1. Raw Data로 정규화 과정까지 수행할 경우 가산점 부여
      2. RDBMS가 아닌 Hadoop, NoSQL 등의 기술을 이용할 경우 사전 구축된 DB를 사용 가능
         1. 사전 구축된 DB 없이 Raw Data를 이용할 경우 가산점 부여
2. 구축된 Data Warehouse에서 SQL 등 질의 언어로 데이터 처리 및 분석
3. R, Python, Excel 등을 이용한 분석 응용

## TODO Issue

- [ ] [[#1]](https://github.com/PresentJay/data-warehousing-sandbox/issues/1) Data Warehouse 개념 정립 (22.06.03 ~ ) :fire:
- [ ] [[#2]](https://github.com/PresentJay/data-warehousing-sandbox/issues/2) Enrich Document
- [ ] [[#3]](https://github.com/PresentJay/data-warehousing-sandbox/issues/3) fake-data-generator in python
- [ ] [[#4]](https://github.com/PresentJay/data-warehousing-sandbox/issues/4) sandbox management: init :fire:

## 주요 목표 마일스톤

- [ ] (1) RDBMS (PostgreSQL) 구축, 전처리가 충분히 된 데이터 활용
- [ ] (2) RDBMS (PostgreSQL) 구축, Raw Data를 획득하여 정규화 등 전처리 수행 (가산점)
- [ ] (3) NoSQL (MongoDB) 구축, Raw Data를 획득하여 정규화 등 전처리 수행 (가산점)

