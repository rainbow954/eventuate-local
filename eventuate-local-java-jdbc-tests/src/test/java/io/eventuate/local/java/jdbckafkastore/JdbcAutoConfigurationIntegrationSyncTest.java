package io.eventuate.local.java.jdbckafkastore;

import io.eventuate.javaclient.spring.tests.common.AbstractAccountIntegrationSyncTest;
import org.junit.runner.RunWith;

import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest(classes = JdbcAutoConfigurationIntegrationTestConfiguration.class)
public class JdbcAutoConfigurationIntegrationSyncTest extends AbstractAccountIntegrationSyncTest {


}