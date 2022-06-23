

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

## Quickstart

1. `./setCmd[.sh/.exe]`
   - 스크립트 OS에 맞게 변경 (win:.exe, mac/linux:.sh)
2. `scripts/startupCluster[.sh/.exe]`
   - `config/cluster.sh`의 설정에 맞게 multipass V-node launch
   - 현재 stable set test: 3-node, 512GB, Ram 8G, CPU 8 core
3. `scripts/bootstrapCluster[.sh/.exe]`
   - Ingress-nginx, longhorn storage, kubernetes-dashboard 설정
4. `scripts/promotheus[.sh/.exe]`
   - promotheus monitoring 설정 (Optional: 지금은 추천하지 않음 . . . Image 바꾸는 것 고려(to bitnami)
5. `scripts/IngressCluster[.sh/.exe] [longhorn, k8s, prometheus, grafana]`
   - 각 dashboard에 대해 ingress 설정 및 실행파일 생성
   - longhorn: `./longhorn[.sh/.exe]`, (mac,linux): `longhorn`
   - kubernetes-dashboard: `./k8s[.sh/.exe]`, (mac,linux): `k8s`
     - 해당 스크립트 실행 시 토큰 같이 주어지며, 해당 토큰의 인증시간은 `무제한`으로 설정됨 (TOKEN-TTL 값 변경 가능: `sec단위`)
   - prometheus: `./prometheus[.sh/.exe]`, (mac,linux): `prometheus`
   - grafana: `./grafana[.sh/.exe]`, (mac,linux): `grafana`
     - default ID: `admin`
     - default PW: `prom-operator`
6. `scripts/zookeeper[.sh/.exe] -i`
   - zookeeper 설치
7. `scripts/clickhouse[.sh/.exe] -i`
   - clickhouse 설치
   - clickhouse ingress: `scripts/IngressCluster[.sh/.exe] clickhouse`
     - default username: `clickhouse_operator`
     - default password: `clickhouse_operator_password`
     - default database: `default`
     - default port: `8123`
   - clickhouse online-query 환경
     - `./clickhouse[.sh/.exe]`
8. `scripts/airbyte[.sh/.exe] -i`
   - airbyte 설치
     - https://docs.airbyte.com/deploying-airbyte/on-kubernetes (beta kustomize 응용)
     - it has a license: https://github.com/airbytehq/airbyte/blob/master/LICENSE 
   - airbyte ingress: `scripts/IngressCluster[.sh/.exe] airbyte`
   - airbyte online-ETL Workflow 환경
     - `./airbyte[.sh/.exe]`


## DWH analysis flow

- [ ] Database
  - https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page
  - Parquet type
  - 2021-07 이후 data에서 raw file을 airflow로 connect
  - clickhouse DWH로 load
- [ ] analysis : [TODO]

