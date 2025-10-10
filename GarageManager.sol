// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GarageManager {
    /* ---------- Struct ---------- */
    struct Car {
        string make;
        string model;
        string color;
        uint numberOfDoors;
    }

    /* ---------- Errors ---------- */
    error BadCarIndex(uint index);

    /* ---------- State ---------- */
    mapping(address => Car[]) private garage;

    /* ---------- Events ---------- */
    event CarAdded(address indexed owner, uint index, string make, string model);
    event CarUpdated(address indexed owner, uint index, string make, string model);
    event GarageReset(address indexed owner);

    /* ---------- Add Car ---------- */
    function addCar(
        string memory make,
        string memory model,
        string memory color,
        uint numberOfDoors
    ) public {
        Car memory newCar = Car(make, model, color, numberOfDoors);
        garage[msg.sender].push(newCar);
        emit CarAdded(msg.sender, garage[msg.sender].length - 1, make, model);
    }

    /* ---------- Get Cars ---------- */
    function getMyCars() public view returns (Car[] memory) {
        return garage[msg.sender];
    }

    function getUserCars(address user) public view returns (Car[] memory) {
        return garage[user];
    }

    /* ---------- Update Car ---------- */
    function updateCar(
        uint index,
        string memory make,
        string memory model,
        string memory color,
        uint numberOfDoors
    ) public {
        if (index >= garage[msg.sender].length) {
            revert BadCarIndex(index);
        }

        Car memory updatedCar = Car(make, model, color, numberOfDoors);
        garage[msg.sender][index] = updatedCar;

        emit CarUpdated(msg.sender, index, make, model);
    }

    /* ---------- Reset Garage ---------- */
    function resetMyGarage() public {
        delete garage[msg.sender];
        emit GarageReset(msg.sender);
    }
}
