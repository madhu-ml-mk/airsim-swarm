import rclpy
from rclpy.node import Node

class GPSSpoofDetectionNode(Node):
    def __init__(self):
        super().__init__('gps_spoof_detection_node')
        self.get_logger().info("GPS Spoof Detection Node started")

def main(args=None):
    rclpy.init(args=args)
    node = GPSSpoofDetectionNode()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
