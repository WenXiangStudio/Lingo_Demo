// spell-checker: disable
// ---------------------------------------------------------------------------
// Template pools for the local scenario-example generator.
// Each template is designed to be semantically neutral — it must work with
// ANY word of that part-of-speech.  {word} = lowercase, {Word} = capitalised.
// ---------------------------------------------------------------------------

const nounTemplates = [
  'The {word} caught my attention right away this morning.',
  'I have always been curious about the {word} since childhood.',
  'She pointed at the {word} with great interest and curiosity.',
  'A {word} like this is hard to find in most places these days.',
  'The {word} turned out to be much more useful than I expected.',
  '{Word} is something we encounter in our daily lives quite often.',
  'I read an interesting article about the {word} just last week.',
  'The {word} has become increasingly popular over the past few years.',
  'He mentioned the {word} several times during our long conversation.',
  'The children were delighted to see the {word} up close and personal.',
  'She took a photo of the {word} to share with her friends online.',
  'I never expected the {word} to be so fascinating and enjoyable.',
  'They spent the whole afternoon talking about the {word} together.',
  'The {word} reminded me of something special from my early childhood.',
  'You can find the {word} in almost every household across the country.',
];

const verbTemplates = [
  'I will {word} as soon as I get the chance later today.',
  'You can {word} this whenever you feel ready to begin.',
  'She tried to {word} but found it more difficult than expected.',
  'They decided to {word} after a long and thoughtful discussion.',
  'He promised to {word} before the end of this busy week.',
  'We should {word} before it gets too late to do anything.',
  'People often {word} when they are under a lot of pressure.',
  'She learned to {word} from her wise and patient grandmother.',
  'He would always {word} with great care and keen attention to detail.',
  'I need to {word} this before the important meeting starts.',
  'They encouraged her to {word} on her own without any outside help.',
  'The children were eager to {word} all by themselves for the first time.',
  'You must {word} carefully to avoid making any unnecessary mistakes.',
  'He paused for a moment and then slowly began to {word}.',
  'She watched quietly as he started to {word} without saying a word.',
];

const adjTemplates = [
  'Everyone agreed that the result was quite {word} indeed.',
  'The whole situation was far more {word} than I had ever expected.',
  'I found the entire experience to be rather {word} and memorable.',
  'She said the outcome was {word} but I was not entirely so sure.',
  'It seemed {word} at first but later it all made perfect sense.',
  'He described the place as {word} and truly unforgettable to visit.',
  'The teacher said my answer was {word} and very well thought out.',
  'Many people think this approach is {word} but honest opinions do vary.',
  'She felt {word} about the important decision she had just made.',
  'The journey was long but absolutely {word} in every possible way.',
  'His performance was considered {word} by every single one of the judges.',
  'I thought the book was {word} though my close friend strongly disagreed.',
  'She looked genuinely {word} as she walked through the front door.',
  'The final result was {word} considering all the effort we had invested.',
];

const advTemplates = [
  'She answered the difficult question {word} during the long interview.',
  'He {word} finished the entire task before anyone else had even started.',
  'The whole team worked {word} to meet the extremely tight deadline.',
  'She {word} explained every step of the procedure to the new employees.',
  'The young children behaved {word} throughout the entire long ceremony.',
  'He {word} accepted the new challenge without any sign of hesitation.',
  'They all {word} agreed to help out with the community clean-up project.',
  'She {word} walked away without saying another single word to anyone.',
  'The careful manager {word} reviewed every document before signing off.',
  'I would {word} recommend this book to anyone learning a second language.',
];

const prepTemplates = [
  'The cat jumped {word} the fence and ran straight into the garden.',
  'She placed the thick book {word} the table before sitting down to eat.',
  'He walked slowly {word} the quiet park on his way home from work.',
  'The old stone bridge {word} the wide river was built over a century ago.',
  'She looked {word} the frosty window and saw snow falling gently outside.',
];

const pronTemplates = [
  '{Word} of the students in the class knew the answer to the hard question.',
  '{Word} in the meeting room agreed that it was a very sensible idea.',
  '{Word} could possibly have predicted what happened next that afternoon.',
  '{Word} is personally responsible for keeping the shared workspace clean.',
  'She asked if {word} had seen her missing keys but nobody had noticed them.',
];

const particleAdvTemplates = [
  'She turned {word} the offer without giving it a second thought.',
  'He stepped {word} to let the children run past him on the path.',
  'They drove {word} without looking back even once on the way.',
  'The noise gradually died {word} as we walked further into the forest.',
  'She put the book {word} and went to answer the front door.',
  'He walked {word} from the argument to avoid saying something he would regret.',
  'The plane took {word} smoothly despite the strong crosswind at the airport.',
  'She called {word} to her friend from across the busy street.',
];

const fallbackTemplates = [
  'The word "{word}" is commonly used in everyday English conversation.',
  'Understanding "{word}" can help you communicate much more effectively.',
  'The idea of "{word}" is important in many different real-life situations.',
  '"{word}" is a useful term you will encounter often in written English.',
  'Learning to use "{word}" correctly will greatly improve your English skills.',
];
