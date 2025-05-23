import { describe, it, expect, beforeEach } from 'vitest';

// Mock implementation for testing Clarity contracts
const mockPrincipal = (address) => ({ address });
const txSender = mockPrincipal('ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM');

// Mock state
let state = {
  admin: txSender,
  resources: new Map(),
  resourceIdCounter: 1
};

// Mock contract functions
const resourceInventory = {
  addResource: (name, category, quantity) => {
    if (txSender.address !== state.admin.address) {
      return { err: 403 };
    }
    
    const resourceId = state.resourceIdCounter;
    state.resources.set(resourceId, {
      name,
      category,
      quantity,
      lastUpdated: 123 // Mock block height
    });
    
    state.resourceIdCounter++;
    return { ok: resourceId };
  },
  
  updateQuantity: (resourceId, newQuantity) => {
    if (txSender.address !== state.admin.address) {
      return { err: 403 };
    }
    
    if (!state.resources.has(resourceId)) {
      return { err: 404 };
    }
    
    const resource = state.resources.get(resourceId);
    state.resources.set(resourceId, {
      ...resource,
      quantity: newQuantity,
      lastUpdated: 123 // Mock block height
    });
    
    return { ok: true };
  },
  
  getResource: (resourceId) => {
    return state.resources.get(resourceId) || null;
  },
  
  setAdmin: (newAdmin) => {
    if (txSender.address !== state.admin.address) {
      return { err: 403 };
    }
    
    state.admin = newAdmin;
    return { ok: true };
  }
};

describe('Resource Inventory Contract', () => {
  beforeEach(() => {
    // Reset state before each test
    state = {
      admin: txSender,
      resources: new Map(),
      resourceIdCounter: 1
    };
  });
  
  it('should add a new resource', () => {
    const result = resourceInventory.addResource(
        'Ventilator',
        'Equipment',
        10
    );
    
    expect(result).toEqual({ ok: 1 });
    
    const resource = resourceInventory.getResource(1);
    expect(resource).toEqual({
      name: 'Ventilator',
      category: 'Equipment',
      quantity: 10,
      lastUpdated: 123
    });
  });
  
  it('should update resource quantity', () => {
    // First add a resource
    resourceInventory.addResource('Ventilator', 'Equipment', 10);
    
    // Then update its quantity
    const result = resourceInventory.updateQuantity(1, 15);
    
    expect(result).toEqual({ ok: true });
    
    const resource = resourceInventory.getResource(1);
    expect(resource.quantity).toBe(15);
  });
  
  it('should not update non-existent resource', () => {
    const result = resourceInventory.updateQuantity(999, 15);
    
    expect(result).toEqual({ err: 404 });
  });
  
});
