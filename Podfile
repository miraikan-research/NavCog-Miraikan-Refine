project 'NavCog3'
inhibit_all_warnings!

def install_pods
  platform :ios, '13.0'
  pod 'OpenCV', :podspec => './podspecs/OpenCV.podspec'
  pod 'boost', :podspec => './podspecs/boost.podspec.json'
  pod 'eigen', :podspec => './podspecs/eigen.podspec.json'
  pod 'picojson', :podspec => './podspecs/picojson.podspec'
  pod 'cereal', :podspec => './podspecs/cereal.podspec'
  pod 'bleloc', :podspec => './podspecs/bleloc.podspec'
  pod 'SSZipArchive', '2.4.2'
  pod 'HLPLocationManager', :podspec => './podspecs/HLPLocationManager.podspec'
end


target 'NavCog3' do
  install_pods
end

target 'NavCogMiraikan' do
  install_pods
end
