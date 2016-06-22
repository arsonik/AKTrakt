source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

abstract_target 'Internal' do
    pod "AKTrakt", :path => "."
    pod "Alamofire", :git => "https://github.com/Alamofire/Alamofire.git", :branch => 'swift3'
    pod "AlamofireImage", :git => "https://github.com/Alamofire/AlamofireImage.git", :branch => 'swift3'

    target 'AKTrakt iOS' do
        platform :ios, '8.0'
    end

    target 'AKTrakt tvOS' do
        platform :tvos, '9.0'
    end

    target 'Tests' do
    end
end


