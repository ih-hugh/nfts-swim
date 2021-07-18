import { assert } from 'chai';
import defaultAwesomeFunction, { awesomeFunction } from '../src';

describe('Integration', function () {
  it('should test default awesome function', function () {
    const expectedVal =
      'I am the Default Awesome Function, fellow comrade! - Dinesh';
    assert(
      defaultAwesomeFunction('Dinesh') === expectedVal,
      'Default not awesome :('
    );
  });

  it('should test awesome function', function () {
    const expectedVal = 'I am just an Awesome Function';
    assert(awesomeFunction() === expectedVal, 'Named awesome :(');
  });
});
