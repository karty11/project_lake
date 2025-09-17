resource "aws_glue_connection" "mysql_connection" {
  name = "bankapp-mysql-connection"

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:mysql://mysql.devproject.svc.cluster.local:3306/bankapp"
    USERNAME            = "root"
    PASSWORD            = "Test@123"
  }

  physical_connection_requirements {
    availability_zone      = "us-west-2a"
    security_group_id_list = [aws_security_group.glue_sg.id]
    subnet_id              = aws_subnet.private_subnet1.id
  }
}
