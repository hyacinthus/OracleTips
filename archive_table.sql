
--ʹ�÷������չ鵵����
--���������� ������
CREATE TABLE CUST_INFO
(
    CUST_ID VARCHAR2(30),
    CUST_NAME VARCHAR2(100),
    ETL_LOAD_DT DATE
)
NOLOGGING COMPRESS;

CREATE INDEX CUST_INFO_IDX ON CUST_INFO (CUST_ID);

--�����鵵�õķ����� �ͷ������� �ƻ�ÿ��һ������
--��������ֻΪ��ʾ����ȫ�棬һ��鵵���������� 
CREATE TABLE CUST_INFO_ARC
(
    CUST_ID VARCHAR2(30),
    CUST_NAME VARCHAR2(100),
    ETL_LOAD_DT DATE
)PARTITION BY RANGE(ETL_LOAD_DT)
(PARTITION CUST_INFO_ARC_INIT 
    VALUES LESS THAN(TO_DATE('20140201','YYYYMMDD'))
)
NOLOGGING COMPRESS;

CREATE INDEX CUST_INFO_ARC_IDX 
    ON CUST_INFO_ARC (CUST_ID) LOCAL;

--���������в������� ����Ҫ�����鵵����������
--��������������ETL_LOAD_DTֻ�ܳ���ͬһ�������
INSERT INTO CUST_INFO VALUES('1','Tom',TO_DATE('20140202','YYYYMMDD'));
COMMIT;

--��������Ƿ���� ���Ϊ1
SELECT COUNT(*) FROM CUST_INFO;

--���ǿ���������ķ��� ���ֻ��һ���ֶ� 
--��HIGH_VALUE�ֶο��Կ������������䶨��
SELECT * FROM USER_TAB_PARTITIONS 
    WHERE TABLE_NAME='CUST_INFO_ARC';

--��������Ϊ�˽����ݹ鵵����ҪΪ��ǰ���ڽ���һ������ 
--ע�����Ƿ�2��2�յ����� ��������ΪС��2��3��
ALTER TABLE CUST_INFO_ARC 
    ADD PARTITION CUST_INFO_ARC_20140202 
        VALUES LESS THAN(TO_DATE('20140203','YYYYMMDD'));

--�ٴβ鿴����״̬������������������
SELECT * FROM USER_TAB_PARTITIONS 
    WHERE TABLE_NAME='CUST_INFO_ARC';

--��������ǰ�����Ǽ������������״̬
--���ǵ�״̬Ӧ�ö���VALID ����USABLE
SELECT T.STATUS,T.* FROM USER_INDEXES T 
    WHERE INDEX_NAME='CUST_INFO_IDX';
SELECT T.STATUS,T.* FROM USER_IND_PARTITIONS T 
    WHERE T.INDEX_NAME='CUST_INFO_ARC_IDX';

--��Ҫ�������������÷����������ԣ����������е����ݽ������½��ķ���
--ע�����ڱ�����������޶�ƥ�䣬����ᱨ������Ȥ�Ŀ������г���
ALTER TABLE CUST_INFO_ARC 
    EXCHANGE PARTITION CUST_INFO_ARC_20140202 
        WITH TABLE CUST_INFO;

--���һ�¼�¼�ǲ����Ѿ��������� ��¼Ӧ���ڷ�������
SELECT COUNT(*) FROM CUST_INFO;
SELECT COUNT(*) FROM CUST_INFO_ARC;

--���������ٴμ������������״̬����������������ά������
--����������������ͱ��������Ǹ�������������ʧЧ��
SELECT T.STATUS,T.* FROM USER_INDEXES T 
    WHERE INDEX_NAME='CUST_INFO_IDX';
SELECT T.STATUS,T.* FROM USER_IND_PARTITIONS T 
    WHERE T.INDEX_NAME='CUST_INFO_ARC_IDX';

--������ɺ���Ҫ�������ؽ�һ�£��ؽ�����������Ҫָ��������
ALTER INDEX CUST_INFO_IDX REBUILD;
ALTER INDEX CUST_INFO_ARC_IDX REBUILD PARTITION CUST_INFO_ARC_20140202;

--�����ٿ�һ�Σ�����״̬�Ѿ������ˡ�
SELECT T.STATUS,T.* FROM USER_INDEXES T 
    WHERE INDEX_NAME='CUST_INFO_IDX';
SELECT T.STATUS,T.* FROM USER_IND_PARTITIONS T 
    WHERE T.INDEX_NAME='CUST_INFO_ARC_IDX';

--��ʵ��������������ƶ���Ӧ�������ռ�ͳ����Ϣ
--�Ա��ѯ�Ż������õĹ�������ע������Ҫ�����û����������滻��
BEGIN DBMS_STATS.GATHER_TABLE_STATS('MART','CUST_INFO');END;
BEGIN DBMS_STATS.GATHER_TABLE_STATS('MART','CUST_INFO_ARC');END;

--�鵵��������ó����ղ��Է����ɾ�����ɵĲ��õ����ݡ�������¡�
ALTER TABLE CUST_INFO_ARC 
    DROP PARTITION CUST_INFO_ARC_INIT;

--���������Ѿ�ֻʣ�����µ�һ���� 
--�������һ���������޷�ɾ���ģ������Լ����ԡ�
SELECT * FROM USER_TAB_PARTITIONS 
    WHERE TABLE_NAME='CUST_INFO_ARC';

--ʵ�鵽�˽��� ɾ�����еı�
DROP TABLE CUST_INFO;
DROP TABLE CUST_INFO_ARC;
