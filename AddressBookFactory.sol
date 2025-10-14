// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/* OpenZeppelin風 Ownable */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract AddressBook is Ownable {
    struct Contact {
        uint id;
        string firstName;
        string lastName;
        uint[] phoneNumbers;
        bool exists;
    }

    mapping(uint => Contact) private contacts;
    uint[] private contactIds;

    error ContactNotFound(uint id);

    // 連絡先追加・更新
    function addContact(
        uint id,
        string calldata firstName,
        string calldata lastName,
        uint[] calldata phoneNumbers
    ) external onlyOwner {
        if (!contacts[id].exists) {
            contactIds.push(id);
        }
        contacts[id] = Contact(id, firstName, lastName, phoneNumbers, true);
    }

    // 連絡先削除
    function deleteContact(uint id) external onlyOwner {
        if (!contacts[id].exists) revert ContactNotFound(id);
        delete contacts[id];

        // contactIds から削除
        for (uint i = 0; i < contactIds.length; i++) {
            if (contactIds[i] == id) {
                contactIds[i] = contactIds[contactIds.length - 1]; // 最後の要素と入れ替え
                contactIds.pop();
                break;
            }
        }
    }

    // 連絡先取得
    function getContact(uint id) external view returns (Contact memory) {
        if (!contacts[id].exists) revert ContactNotFound(id);
        return contacts[id];
    }

    // 全連絡先取得
    function getAllContacts() external view returns (Contact[] memory) {
        uint count = contactIds.length;
        Contact[] memory list = new Contact[](count);
        for (uint i = 0; i < count; i++) {
            list[i] = contacts[contactIds[i]];
        }
        return list;
    }
}

contract AddressBookFactory {
    event AddressBookDeployed(address indexed owner, address addressBook);

    function deploy() external returns (address) {
        AddressBook book = new AddressBook();
        // Factoryがオーナーなので、呼び出し元に権限移譲
        book.transferOwnership(msg.sender);
        emit AddressBookDeployed(msg.sender, address(book));
        return address(book);
    }
}
