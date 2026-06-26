function tests = test_fontMethods()
tests = functiontests(localfunctions);
end

function testFontCreateAndCachedBitmap(~)
%% Cached font files load from ISETCam data/fonts with stable bitmap values.

font = fontCreate('g','Georgia',14,96);
bitmap = fontGet(font,'bitmap');
standaloneBitmap = fontBitmapGet(font);

assert(strcmp(fontGet(font,'type'),'font'));
assert(strcmp(fontGet(font,'name'),'g-georgia-14-96'));
assert(strcmp(fontGet(font,'character'),'g'));
assert(strcmp(fontGet(font,'family'),'Georgia'));
assert(strcmp(fontGet(font,'style'),'NORMAL'));
assert(fontGet(font,'size') == 14);
assert(fontGet(font,'dpi') == 96);

assert(isequal(size(bitmap),[13 9 3]));
assert(isequal(bitmap,standaloneBitmap));
assert(min(bitmap(:)) == 0);
assert(max(bitmap(:)) == 1);
assert(abs(mean(bitmap(:)) - 0.532763532763533) < 1e-12);

end

function testFontCreateAndUncachedBitmap(~)
%% Uncached fonts render into valid RGB bitmaps and non-black scenes.

fontSpecs = { ...
    'A', 'Georgia', 18, 96; ...
    'Z', 'Georgia', 14, 96};

for ii = 1:size(fontSpecs, 1)
    font = fontCreate(fontSpecs{ii, :});
    bitmap = fontGet(font, 'bitmap');

    assert(ndims(bitmap) == 3);
    assert(all(size(bitmap, [1 2]) > 1));
    assert(size(bitmap, 3) == 3);
    assert(all(bitmap(:) == 0 | bitmap(:) == 1));
    assert(any(bitmap(:) == 0));
    assert(any(bitmap(:) == 1));

    if ii == 1
        scene = sceneCreate('letter', font, displayCreate('LCD-Apple'), ...
            [7 7], 0);
        photons = sceneGet(scene, 'photons');
        luminance = sceneGet(scene, 'luminance');
        assert(sceneGet(scene, 'mean luminance') > 0);
        assert(any(photons(:) > 0));
        assert(all([luminance(1,1), luminance(1,end), ...
            luminance(end,1), luminance(end,end)] == 0));
    end
end

end

function testFontPaddingAndInversion(~)
%% Padded and inverted font bitmaps preserve expected geometry and values.

font = fontCreate('g','Georgia',14,96);
bitmap = fontGet(font,'bitmap');

padded = fontGet(font,'padded bitmap',[2 3],0);
inverted = fontGet(font,'i bitmap');
invertedPadded = fontGet(font,'i padded bitmap');

assert(isequal(size(padded),[17 15 3]));
assert(padded(1,1,1) == 0);
assert(isequal(padded(3:15,4:12,:),bitmap));
assert(isequal(inverted,1 - bitmap));
assert(isequal(invertedPadded,1 - fontGet(font,'padded bitmap')));

end

function testFontSetRebuildsBitmap(~)
%% Font setters update fields and rebuild bitmap from cached font data.

font = fontCreate('g','Georgia',14,96);
font = fontSet(font,'character','l');
font = fontSet(font,'dpi',72);

assert(strcmp(fontGet(font,'name'),'l-georgia-14-72'));
assert(strcmp(fontGet(font,'character'),'l'));
assert(fontGet(font,'dpi') == 72);
assert(isequal(size(fontGet(font,'bitmap')),[11 4 3]));
assert(abs(mean(fontGet(font,'bitmap'),'all') - 0.598484848484849) < 1e-12);

end

function testSceneCreateLetterFromFont(~)
%% sceneCreate('letter') converts font display radiance into a scene.

font = fontCreate('g','Georgia',14,96);
scene = sceneCreate('letter',font,displayCreate('LCD-Apple'));
photons = sceneGet(scene,'photons');

assert(strcmp(sceneGet(scene,'name'),'g-georgia-14-96'));
assert(isequal(sceneGet(scene,'size'),[540 460]));
assert(isequal(size(sceneGet(scene,'wave')),[101 1]));
assert(abs(sceneGet(scene,'fov') - 0.697302954211194) < 1e-12);
assert(abs(sceneGet(scene,'mean luminance') - 107.875623257568) < 1e-10);
assert(all(isfinite(photons(:))));
assert(all(photons(:) >= 0));

end
