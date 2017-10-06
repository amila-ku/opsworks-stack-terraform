resource "aws_iam_instance_profile" "opsworks" {
  name = "pocapp-${var.env}"

  role = "${aws_iam_role.opsworks.name}"

  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "aws_iam_role" "opsworks" {
  name = "pocapp-opsworks-${var.env}"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "*"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "opsworks" {
    name = "pocapp-policy"
    role = "${aws_iam_role.opsworks.id}"
    policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "ec2:*",
                "iam:PassRole",
                "iam:*",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:DescribeAlarms",
                "ecs:*",
                "elasticloadbalancing:*",
                "rds:*",
                "opsworks:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}


