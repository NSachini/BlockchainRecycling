// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
contract ProductTracker {
    struct ProductLifecycle {
        string barcode;
        string name;
        string category;
        address manufacturer; // Address of the manufacturer
        uint256 manufactureTimestamp;
        // Additional fields can be added as needed
        // List of lifecycle events
        // e.g., "manufactured", "distributed", "sold", "status_update_in_use", "disposed"
        // Each event can have a type, timestamp, details, and actor
        // actor is the address of the entity performing the action (manufacturer, retailer, consumer)
        LifecycleEvent[] events;
    }

    struct LifecycleEvent {
        string eventType; // e.g., "manufactured", "distributed", "sold", "status_update_in_use", "disposed"
        uint256 timestamp;
        string details; // Additional details about the event
        address actor; // Address of the entity performing the action
    }

    mapping(string => ProductLifecycle) public products; // Mapping from product barcode to its lifecycle data
    mapping(string => bool) public productExists; // To check if a product with a given barcode exists
    // Events to log product registration and lifecycle events
    // These events can be used to track product registration and lifecycle changes

    event ProductRegistered(string barcode, string name, address manufacturer, uint256 timestamp);
    event LifecycleEventRecorded(string barcode, string eventType, address actor, uint256 timestamp);

    // Owner of the contract, could be an admin or manufacturer
    address public owner; 

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Function to register a new product with its lifecycle data
    // This function allows the owner to register a new product with its barcode, name, category, and manufacturer address  
    function registerProduct(
        string memory _barcode,
        string memory _name,
        string memory _category,
        address _manufacturer
    ) public onlyOwner {
        require(!productExists[_barcode], "Product with this barcode already exists");

        ProductLifecycle storage newProduct = products[_barcode];
        newProduct.barcode = _barcode;
        newProduct.name = _name;
        newProduct.category = _category;
        newProduct.manufacturer = _manufacturer;
        newProduct.manufactureTimestamp = block.timestamp;
        productExists[_barcode] = true;

        newProduct.events.push(LifecycleEvent({
            eventType: "manufactured",
            timestamp: block.timestamp,
            details: "Product manufactured",
            actor: _manufacturer
        }));

        emit ProductRegistered(_barcode, _name, _manufacturer, block.timestamp);
    }

    // Function to record a lifecycle event for a product
    // This function allows any entity (manufacturer, retailer, consumer) to record an event in the product's lifecycle
    function recordLifecycleEvent(
        string memory _barcode,
        string memory _eventType,
        string memory _details,
        address _actor
    ) public {
        require(productExists[_barcode], "Product not found");

        ProductLifecycle storage product = products[_barcode];
        product.events.push(LifecycleEvent({
            eventType: _eventType,
            timestamp: block.timestamp,
            details: _details,
            actor: _actor
        }));

        emit LifecycleEventRecorded(_barcode, _eventType, _actor, block.timestamp);
    }

    // Function to get the lifecycle events of a product
    // This function allows anyone to retrieve the lifecycle events of a product by its barcode
    function getProductEvents(string memory _barcode) public view returns (LifecycleEvent[] memory) {
        require(productExists[_barcode], "Product not found");
        return products[_barcode].events;
    }
}