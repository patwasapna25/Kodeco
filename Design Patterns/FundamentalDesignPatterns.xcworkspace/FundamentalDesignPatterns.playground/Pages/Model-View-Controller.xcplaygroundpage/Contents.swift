/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Model-view-controller (MVC)
 - - - - - - - - - -
 ![MVC Diagram](MVC_Diagram.png)
 
 The model-view-controller (MVC) pattern separates objects into three types: models, views and controllers.
 
 **Models** hold onto application data. They are usually structs or simple classes.
 
 **Views** display visual elements and controls on screen. They are usually subclasses of `UIView`.
 
 **Controllers** coordinate between models and views. They are usually subclasses of `UIViewController`.
 
 ## Code Example
 */
import UIKit

// MARK: Model
public struct Address {
    public var street: String
    public var city: String
    public var state: String
    public var zipCode: String
}

// MARK: View
public final class AddressView: UIView {
    @IBOutlet public var streetTextFeild: UITextField!
    @IBOutlet public var cityTextFeild: UITextField!
    @IBOutlet public var stateTextFeild: UITextField!
    @IBOutlet public var zipCodeTextFeild: UITextField!
}

// MARK: Controller
public final class AddressViewController: UIViewController {
    
    public var address: Address? {
        didSet {
            updateViewFromAddress()
        }
    }
    public var addressView: AddressView! {
        guard isViewLoaded else {
            return nil
        }
        return (view as! AddressView)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromAddress()
    }
    
    private func updateViewFromAddress() {
        guard let addressView, let address else {
            return
        }
        addressView.streetTextFeild.text = address.street
        addressView.cityTextFeild.text = address.city
        addressView.stateTextFeild.text = address.state
        addressView.zipCodeTextFeild.text = address.zipCode
    }
    
    @IBAction func updateAddressFromView(_ sender: AnyObject) {
        guard let street = addressView.streetTextFeild.text, street.count > 0,
        let city = addressView.cityTextFeild.text, city.count > 0,
        let state = addressView.stateTextFeild.text, state.count > 0,
        let zipCode = addressView.zipCodeTextFeild.text, zipCode.count > 0 else {
            return
        }
        
        address = Address(street: street, city: city, state: state, zipCode: zipCode)
    }
}
