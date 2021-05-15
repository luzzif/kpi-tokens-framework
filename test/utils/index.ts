export const encodeRealityQuestion = (question: string): string => {
    question = JSON.stringify(question).replace(/^"|"$/g, "");
    return `${question}\u241fkpi\u241fen_US`;
};
