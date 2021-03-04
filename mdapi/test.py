from tf_detector import TFDetector

tf_detector = TFDetector(model_path='md_v4.1.0.pb', output_path='/mnt/home/billspat/docs/wilton/output')

results = tf_detector.run_detection(input_path='/tmp/billspat/mo')
print(results)
